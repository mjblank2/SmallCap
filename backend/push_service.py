"""
Push notification service with APNs client integration.

Compatibility Note
------------------
`apns2` depends on `hyper`, and older versions of `hyper` try to import
abstract base classes like `Iterable` and `Mapping` directly from the
collections module. In Python 3.10+, those names live in collections.abc.
This shim adds these attributes back into collections if they are missing.
"""

from __future__ import annotations

import collections
import collections.abc

# Backwards-compatibility shim
for _name in ("Iterable", "Mapping", "MutableMapping", "MutableSet", "MutableSequence", "Sequence", "Set"):
    if not hasattr(collections, _name):
        setattr(collections, _name, getattr(collections.abc, _name))

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
