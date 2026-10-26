# App config.
import os

SECRET_KEY = os.environ.get("SECRET_KEY", "dev-not-a-real-flask-secret-key")

# Moved out of source — read from environment at runtime.
AWS_ACCESS_KEY_ID = os.environ.get("AWS_ACCESS_KEY_ID", "")
AWS_SECRET_ACCESS_KEY = os.environ.get("AWS_SECRET_ACCESS_KEY", "")
