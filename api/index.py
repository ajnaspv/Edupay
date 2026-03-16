import os
import sys

# add project root to python path
sys.path.append(os.path.dirname(os.path.dirname(__file__)))

# Django settings
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "Edupay.settings")

from django.core.wsgi import get_wsgi_application

app = get_wsgi_application()