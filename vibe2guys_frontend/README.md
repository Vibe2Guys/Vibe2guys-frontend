# Vibe2Guys Frontend (Flutter Web)

Role-based LMS frontend MVP for `STUDENT` and `INSTRUCTOR`, aligned to shared API response rules:

- Base URL: `/api/v1`
- Success: `{"success": true, "message": "...", "data": ...}`
- Error: `{"success": false, "message": "...", "errorCode": "..."}`
- Auth: `Authorization: Bearer {accessToken}`

## Run

```bash
flutter pub get
flutter run -d chrome
```

## Real API Mode

Default mode is `MockApiClient`.
Switch to real backend with `dart-define`:

```bash
flutter run -d chrome \
  --dart-define=USE_REAL_API=true \
  --dart-define=API_BASE_URL=http://localhost:8080/api/v1
```

## API Layer

- `lib/core/api_client.dart`: common interface
- `lib/core/mock_api_client.dart`: mock data implementation
- `lib/core/http_api_client.dart`: HTTP implementation + response normalization

`HttpApiClient` normalizes list-like responses from:

- `data` as a list
- `data.content` (paginated response)
- `data.messages` (chat response)
