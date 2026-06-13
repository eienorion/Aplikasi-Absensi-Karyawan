<?php

namespace App\Http\Controllers;

use Google\Client;
use Google\Service\Drive;
use Illuminate\Http\Request;

class GoogleAuthController extends Controller
{
    public function redirect()
    {
        $client = $this->makeClient();

        return redirect($client->createAuthUrl());
    }

    public function callback(Request $request)
    {
        if (!$request->has('code')) {
            return response()->json([
                'message' => 'Authorization code tidak ditemukan.',
            ], 400);
        }

        $client = $this->makeClient();

        $token = $client->fetchAccessTokenWithAuthCode($request->code);

        if (isset($token['error'])) {
            return response()->json([
                'message' => 'Gagal mengambil token.',
                'error' => $token,
            ], 400);
        }

        return response()->json([
            'message' => 'Berhasil mendapatkan token.',
            'access_token' => $token['access_token'] ?? null,
            'refresh_token' => $token['refresh_token'] ?? null,
            'note' => 'Copy refresh_token ke .env bagian GOOGLE_REFRESH_TOKEN. Kalau refresh_token null, buka URL redirect lewat incognito atau revoke akses app di akun Google lalu coba lagi.',
        ]);
    }

    private function makeClient(): Client
    {
        $client = new Client();

        $client->setClientId(config('services.google_oauth.client_id'));
        $client->setClientSecret(config('services.google_oauth.client_secret'));
        $client->setRedirectUri(config('services.google_oauth.redirect_uri'));

        $client->addScope(Drive::DRIVE);
        $client->setAccessType('offline');
        $client->setPrompt('consent');

        return $client;
    }
}