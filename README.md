# MicroCap Daily - Investment Intelligence Platform

## Architecture
- **Backend:** Python/Flask/Celery hosted on Render.com.
- **Database/Cache:** PostgreSQL & Redis (Render).
- **iOS Client:** Native Swift/SwiftUI (MVVM).
- **Data Providers:** Polygon.io and Tiingo.
- **CI/CD:** Codemagic.io.

## Setup Instructions (Summary)

1. **Backend (Render.com):** Connect this repository to Render. Use `render.yaml`. Configure API keys in the `microcap-secrets` Environment Group. Initialize the PostgreSQL database via the Render Shell after deployment.
2. **iOS (Codemagic.io):** Ensure Xcode project files exist in `/ios/`. Connect this repository to Codemagic. Configure App Store Connect credentials and Code Signing Certificates in the Codemagic dashboard.
