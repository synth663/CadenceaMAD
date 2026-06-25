import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'cadencea.settings')
django.setup()

from django.contrib.auth import get_user_model
User = get_user_model()

superusers = User.objects.filter(is_superuser=True)
if not superusers.exists():
    print("No superuser found. Creating one...")
    User.objects.create_superuser('admin', 'admin@cadencea.io', 'admin')
    print("Created superuser: admin / admin")
else:
    for u in superusers:
        print(f"Found superuser. Username: {getattr(u, 'username', 'N/A')} | Email: {getattr(u, 'email', 'N/A')}")
        u.set_password('admin')
        u.save()
        print("Password reset to 'admin' for this user.")
