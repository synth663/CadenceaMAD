"""
Custom User Model
=================
UUID primary key user model with role-based access control.
Matches the schema in BACKEND_STRUCTURE.md.
"""

import uuid
from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    """
    Custom user with UUID primary key and role field.

    Fields:
        id          UUID    — Primary key (auto-generated)
        username    str     — Unique username
        email       str     — Unique email address
        password    str     — Hashed password (Django PBKDF2)
        role        str     — 'user' or 'admin'
        date_joined datetime — Auto-set on creation
    """

    class Role(models.TextChoices):
        USER = 'user', 'User'
        ADMIN = 'admin', 'Admin'

    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False,
    )
    email = models.EmailField(
        unique=True,
        max_length=254,
        error_messages={'unique': 'A user with this email already exists.'},
    )
    role = models.CharField(
        max_length=20,
        choices=Role.choices,
        default=Role.USER,
    )

    # Use email as the login field
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

    class Meta:
        db_table = 'auth_user'
        verbose_name = 'User'
        verbose_name_plural = 'Users'

    def __str__(self):
        return f"{self.username} ({self.email})"
