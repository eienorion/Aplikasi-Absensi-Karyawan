<?php

namespace App\Services;

use Google\Client;
use Google\Service\Drive;
use Google\Service\Drive\DriveFile;
use Google\Service\Drive\Permission;
use Illuminate\Http\UploadedFile;

class GoogleDriveService
{
    private Drive $drive;
    private string $rootFolderId;

  public function __construct()
{
    $clientId = config('services.google_oauth.client_id');
    $clientSecret = config('services.google_oauth.client_secret');
    $redirectUri = config('services.google_oauth.redirect_uri');
    $refreshToken = config('services.google_oauth.refresh_token');
    $folderId = config('services.google_oauth.folder_id');

    if (!$clientId || !$clientSecret || !$redirectUri) {
        throw new \Exception('Google OAuth client belum lengkap di .env.');
    }

    if (!$refreshToken) {
        throw new \Exception('GOOGLE_REFRESH_TOKEN belum diisi di .env.');
    }

    if (!$folderId) {
        throw new \Exception('GOOGLE_DRIVE_FOLDER_ID belum diisi di .env.');
    }

    $client = new Client();
    $client->setClientId($clientId);
    $client->setClientSecret($clientSecret);
    $client->setRedirectUri($redirectUri);
    $client->addScope(Drive::DRIVE);

    $client->fetchAccessTokenWithRefreshToken($refreshToken);

    $this->drive = new Drive($client);
    $this->rootFolderId = $folderId;
}
    public function uploadAttendancePhoto(
        UploadedFile $file,
        string $employeeName,
        string $attendanceType
    ): array {
        $year = now()->format('Y');
        $month = now()->format('m');

        $yearFolderId = $this->getOrCreateFolder($year, $this->rootFolderId);
        $monthFolderId = $this->getOrCreateFolder($month, $yearFolderId);

        $safeName = preg_replace('/[^A-Za-z0-9_\-]/', '_', $employeeName);

        $fileName = $safeName . '_' .
            $attendanceType . '_' .
            now()->format('Ymd_His') . '.' .
            $file->getClientOriginalExtension();

        $fileMetadata = new DriveFile([
            'name' => $fileName,
            'parents' => [$monthFolderId],
        ]);

        $uploadedFile = $this->drive->files->create($fileMetadata, [
            'data' => file_get_contents($file->getRealPath()),
            'mimeType' => $file->getMimeType(),
            'uploadType' => 'multipart',
            'fields' => 'id, name, webViewLink',
        ]);

        $permission = new Permission([
            'type' => 'anyone',
            'role' => 'reader',
        ]);

        $this->drive->permissions->create($uploadedFile->id, $permission);

        return [
            'drive_id' => $uploadedFile->id,
            'file_name' => $fileName,
            'folder' => $year . '/' . $month,
            'path' => $year . '/' . $month . '/' . $fileName,
            'url' => $uploadedFile->webViewLink
                ?? 'https://drive.google.com/file/d/' . $uploadedFile->id . '/view',
        ];
    }

    private function getOrCreateFolder(string $folderName, string $parentId): string
    {
        $escapedFolderName = str_replace("'", "\\'", $folderName);

        $query = "name='{$escapedFolderName}' "
            . "and mimeType='application/vnd.google-apps.folder' "
            . "and '{$parentId}' in parents "
            . "and trashed=false";

        $results = $this->drive->files->listFiles([
            'q' => $query,
            'fields' => 'files(id, name)',
        ]);

        if (count($results->files) > 0) {
            return $results->files[0]->id;
        }

        $folderMetadata = new DriveFile([
            'name' => $folderName,
            'mimeType' => 'application/vnd.google-apps.folder',
            'parents' => [$parentId],
        ]);

        $folder = $this->drive->files->create($folderMetadata, [
            'fields' => 'id',
        ]);

        return $folder->id;
    }
}