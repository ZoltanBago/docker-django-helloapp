# 1. Alap image megadása (Pl. Python 3.11 slim)
FROM python:3.11-slim
# 2. Környezeti változók beállítása
ENV PYTHONUNBUFFERED 1
ENV DJANGO_PROJECT_NAME docker_django
ENV PORT 8000# 3. Munkakönyvtár létrehozása és beállítása a konténerben
WORKDIR /usr/src/app
# 4. Függőségek másolása és telepítése
# Ez a lépés külön réteget képez, így ha csak a kód változik,
# a függőségek újratelepítése nem történik meg
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
# 5. A teljes projektkód másolása a munkakönyvtárba
COPY . .
# 6. A port megnyitása
EXPOSE 8000
# 7. Konténer indítási parancsa (Gunicorn használatával)
# A Gunicorn futtatja a Django projektet a wsgi.py fájlon keresztül.
# A 'project.wsgi:application' helyére a fő projektmappád nevét írd.
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "docker_django.wsgi:application"]