"""
Django command to wait for the database to be available.
"""
import time

from django.core.management.base import BaseCommand
from django.db.utils import OperationalError
import psycopg2


class Command(BaseCommand):
    """Django command to wait for database."""

    def handle(self, *args, **options):
        """Handle the command to wait for the database."""
        self.stdout.write("Waiting for database...")
        db_up = False
        while not db_up:
            try:
                self.check(databases=["default"])
                db_up = True
            except (psycopg2.OperationalError, OperationalError):
                self.stdout.write("Database unavailable, waiting 1 second...")
                time.sleep(1)

        self.stdout.write(self.style.SUCCESS("Database available!"))
