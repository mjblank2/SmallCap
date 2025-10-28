import os
from apns2.client import APNsClient
from apns2.payload import Payload
from config import Config

class PushNotificationService:
    def __init__(self):
        self.apns_client = None
        if Config.APNS_KEY_ID and Config.APNS_TEAM_ID and os.path.exists(Config.APNS_KEY_FILE_PATH):
            try:
                self.apns_client = APNsClient(
                    team_id=Config.APNS_TEAM_ID,
                    auth_key_id=Config.APNS_KEY_ID,
                    auth_key_filepath=Config.APNS_KEY_FILE_PATH,
                    use_sandbox=Config.APNS_IS_SANDBOX,
                )
            except Exception as e:
                print(f"Failed to initialize APNsClient: {e}")
        else:
            print("APNs not configured. Missing KEY_ID, TEAM_ID, or Key File.")

    def send_notification(self, device_token, alert_title, alert_body):
        """Sends a single push notification."""
        if not self.apns_client:
            print(f"Simulating Push (APNs not configured): TO={device_token}, TITLE={alert_title}")
            return

        try:
            payload = Payload(
                alert={"title": alert_title, "body": alert_body},
                sound="default",
                badge=1,
                mutable_content=True
            )
            
            # Send the notification
            self.apns_client.send_notification(
                device_token, 
                payload, 
                topic=Config.APNS_BUNDLE_ID
            )
            print(f"Successfully sent push to {device_token}")

        except Exception as e:
            print(f"Failed to send push notification to {device_token}: {e}")
            # Handle potential errors, e.g., 'BadDeviceToken'
            # If 'BadDeviceToken', you should remove the token from the database.

# Singleton instance
PNS = PushNotificationService()
