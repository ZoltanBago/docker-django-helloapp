# Docker Django helloapp

Egy olyan Django appot készítünk, amely a *„Hello, Docker Django!”* üzenetet jeleníti meg a weboldalon, a Dockerben fog futni és a GitHub-ra feltöltve bárki klónozhatja és elindíthatja.

## A projekt inicializálása

Hozzunk létre egy könyvtárat **docker_django** néven:

    mkdir docker_django

Lépjünk be a könyvtárba:

    cd docker_django

Hozzuk létre a virtuális környezetet:

    python3 -m venv venv

Aktiváljuk a virtuális környezetet:

    source venv/bin/activate

A pip segítségével telepítsük a Djangót:

    pip install django

Hozzuk létre a konfigurációs könyvtárat **config** néven:

    django-admin startproject config .

Hozzuk létre a **hello** nevű appot:

    django-admin startapp hello

## Az app beállítása

Lépjünk be a konfigurációs könyvtárba és regisztráljuk az appot a **settings.py** fájlban:

**config/settings.py**

    INSTALLED_APPS = [
        'django.contrib.admin',
        'django.contrib.auth',
        'django.contrib.contenttypes',
        'django.contrib.sessions',
        'django.contrib.messages',
        'django.contrib.staticfiles',
        'hello',  # új app
    ]

    ALLOWED_HOSTS = ['*']

## A nézet beállítása

**hello/views.py**

    from django.http import HttpResponse

    def index(request):
        return HttpResponse("Hello, Docker Django!")

## Az URLs beállítása

**hello/urls.py**

    from django.urls import path
    from . import views

    urlpatterns = [
         path('', views.index, name='index'),
    ]

**config/urls.py**

    from django.contrib import admin
    from django.urls import path, include

    urlpatterns = [
        path('admin/', admin.site.urls),
        path('', include('hello.urls')),
    ]

## A követelmények fájl létrehozása:

A követelmények (requirements) fájlt a **pip freeze** segítségével hozhatjuk létre:

    pip freeze > requirements.txt

A pip freeze automatikusan létrehozza a requirements.txt tartalmát.

## Dockerfile létrehozása

**docker_django/Dockerfile**

    # 1. Alap image
    FROM python:3.12-slim

    # 2. Munkakönyvtár
    WORKDIR /app

    # 3. Követelmények
    COPY requirements.txt .
    RUN pip install --no-cache-dir -r requirements.txt

    # 4. Kód másolása
    COPY . .

    # 5. Port és futtatás
    EXPOSE 8000
    CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

## A .dockerignore fájl létrehozása

A Docker build előtt hozzunk létre egy szöveges fájlt **.dockerignore** néven.

    # Figyelmen kívül hagyandó Docker specifikus fájlok
    Dockerfile
    .dockerignore

    # Git és verziókövetés
    .git
    .gitignore

    # Python és Virtuális Környezet
    venv
    env
    __pycache__
    *.pyc

    # Titkos adatok és Logok
    .env
    local_settings.py
    *.log
    db.sqlite3

    # IDE és Rendszerfájlok
    .vscode
    .idea
    .DS_Store

A **.dockerignore** azokat a felesleges adatokat tartalmazza, amelyeknek nem kellenek a build-hez. Ez egy titkosított fájl lesz, mert a neve előtt van a pont és nem látszódik a fájlok között. A Linux terminálban azonban az **ls -a** paranccsal elérhető. 

## Docker build és futtatás

    docker build -t docker_django .

A kimenet végén ennek kell látszódnia:

    Sending build context to Docker daemon  43.01kB
    Step 1/7 : FROM python:3.12-slim
     ---> 324231aabbd8
    Step 2/7 : WORKDIR /app
     ---> Using cache
     ---> 1c288f2061cc
    Step 3/7 : COPY requirements.txt .
     ---> Using cache
     ---> 1f95c0e7d610
    Step 4/7 : RUN pip install --no-cache-dir -r requirements.txt
     ---> Using cache
     ---> 2598e3c57cb9
    Step 5/7 : COPY . .
     ---> da5242748426
    Step 6/7 : EXPOSE 8000
     ---> Running in 5764a5cf7671
    Removing intermediate container 5764a5cf7671
     ---> 91110dc7381f
    Step 7/7 : CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
     ---> Running in 9f1ddb2fee1d
    Removing intermediate container 9f1ddb2fee1d
     ---> d4fb69ea768e
    Successfully built d4fb69ea768e
    Successfully tagged docker_django:latest

Miután felépítettük a Dockert futtassuk a terminálban:

    docker run -p 8000:8000 docker_django

Nyissuk meg a http://localhost:8000 portot és láthatjuk, hogy beadja az üdvözlőképernyőt a *"Hello, Django Docker!"* felirattal.

    Watching for file changes with StatReloader
    [04/Nov/2025 12:37:40] "GET / HTTP/1.1" 200 21

Állítsuk le a Docker futását a Ctrl+C billentyű kombinációval.

## A .gitignore fájl létrehozása

Mielőtt feltöltjük a GitHub-ra hozzuk létre a **.gitignore** fájlt. A .gitignore fájlra azért van szükségünk, hogy elkerüljük a felesleges tartalom feltöltését. 

**docker_django/.gitignore**

    # Python és virtuális környezet
    venv/
    env/
    __pycache__/
    *.pyc
    *.log

    # Django SQLite adatbázis
    db.sqlite3
    *.sqlite3

    # Média és statikus fájlok 
    /media
    /staticfiles

    # Titkos konfigurációs fájlok
    .env
    local_settings.py

    # IDE-k és Rendszerek
    .vscode/        
    .idea/          
    *.sublime-project
    *.sublime-workspace

    # Operációs Rendszer
    .DS_Store       
    Thumbs.db       

## Feltöltés a GitHub-ra

A **docker_django** könyvtár inicializálása:

    git init

A kimenet: 

    Initialized empty Git repository in /home/bagozoltan/docker_django/.git/

Adjuk hozzá az összes fájlt, ami a könyvtárban van:

    git add .

Készítsünk egy commit-ot: 

    git commit -m "Initial Docker Django"

    git branch -M main

A feltöltéshez az SSH-t használjuk:

    git remote add origin git@github.com:ZoltanBago/docker-django-helloapp.git

Töltsük fel:

    git push -u origin main

Az SSH kérni fogja a jelszót, ami után megkezdődik a feltöltés.

## Licenc

Ez a projekt a [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/) licenc alatt érhető el.  

Szabadon másolható, tanulmányozható és módosítható **nem kereskedelmi célra**, a szerző (Bagó Zoltán) nevének feltüntetése mellett.

Kereskedelmi felhasználás esetén külön engedély szükséges.