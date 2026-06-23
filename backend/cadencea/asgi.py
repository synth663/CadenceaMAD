"""
ASGI config for Cadencea project.
"""

import os
from django.core.asgi import get_asgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'cadencea.settings')
application = get_asgi_application()
