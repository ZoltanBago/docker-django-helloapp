# Docker Django Repository
Ez a dokumentáció egy egyszerű Django alkalmazás becsomagolását mutatja be a Dockerbe.

1. Django app létrehozása
2. Docker konténer létrehozása
3. Feltöltés a GitHub-ra

Hozzunk létre egy könyvtárat a terminál segítségével:

    $ mkdir django_project

Hozzuk létre a Python virtuális környezetet venv néven:

    python3 -m venv venv

Aktiváljuk a virtuális környezetet:

    (venv) $ activate
    $

Telepítsük a Djangót a pip segítségével:

pip install django

Telepítsük a **freeze** csomagot:

    pip install freeze

Hozzuk létre a projektünk **docker_django** nevű könyvtárát, amelyben a konfigurációs fájlok lesznek:

    django-admin startproject docker_django

Ellenörizzük szervert:

    python3 manage.py runserver

A Django rakétás üdvözlő képernyőjének kell bejönnie. Ezután állítsuk le a szervert a Ctrl+C billentyű kombináció segítségével.

## 1. Django app létrehozása
Hozzuk létre a Django alkalmazásunkat, amelynek a neve az lesz, hogy hello. Azért ez a neve, mert egy üres üdvözlőképernyőt fog mutatni a "Hello Docker Django!" felirattal.

    python3 manage.py startapp hello

Ezzel létrejön egy könyvtár a **docker_django** projekt könyvtárban.

A következő lépés az app regisztrálása a **settings.py** fájlban.

Nyissuk meg a fájlt és írjuk be az INSTALLED_APPS utolsó sorába a **'hello'** nevet.

**docker_django/settings.py**

    # Application definition

    INSTALLED_APPS = [
        'django.contrib.admin',
        'django.contrib.auth',
        'django.contrib.contenttypes',
        'django.contrib.sessions',
        'django.contrib.messages',
        'django.contrib.staticfiles',
        'hello',
    ]

Mentsük el a fájlt és ezzel elvégeztük a regisztrációt.

Menjünk a **hello** könyvtárba és nyissuk meg a **views.py** fájlt. 

**hello/views.py**

    from django.shortcuts import render
    
    # Create your views here.

A **views.py** fájl nagyrészt üres, nekünk kell kitölteni tartalommal. Töröljük ki a komment mezőt és modosítsuk a kódot:

    from django.http import HttpResponse
    from django.shortcuts import render

    def home_page_view(request):
        return HttpResponse("Hello Docker Django!")

Mentsük el és hozzunk létre egy új fájlt a **hello** könyvtárban **urls.py** néven.

Nyissuk meg a fájlt és töltsük fel tartalommal:

    from django.urls import path
    from .views import home_page_view
    
    urlpatterns = [
        path("", home_page_view),
    ]

Ezután menjünk a **docker_django** konfigurációs könyvtárunkba és nyissuk meg az ugyanilyen névre hallgató **urls.py** fájlt és módosítsuk a tartalmát:

**docker_django/urls.py**

    from django.contrib import admin
    from django.urls import path, include
   
    urlpatterns = [
        path("admin/", admin.site.urls),
        path("", include("hello.urls")),
    ]

Adjuk hozzá az **include** és az új **path("", include("hello.urls")),** útvonalat. 

Futtassuk a szervert:

    python3 manage.py runserver

A http://127.0.0.1:8000/ porton meg fog jelenni a *"Hello Docker Django!"* üdvözlő felírat. 

Ezzel befejeztük a Django app-ra vonatkozó teendőinket. Ez egy egyszerű app, ami nagyon alapvető, nincsen benne semmi különösebb csavar. Nekünk most az a lényeg, hogy előkészítjük a GitHubra történő feltöltésre, becsomagoljuk egy Docker konténerbe és utána feltoljuk a cuccot a GitHub-ra.

A következő lépés, hogy a meglévő GitHub repónkba előkészítjük a feltöltést. Ehhez a **docker_django** konfigurációs könyvtárunkban maradunk és kiadjuk a szükséges git parancsot:

    git init

Ezután meg nézzük az állapotát a könyvtárunknak:

    git status

Ha minden rendben van, akkor készítünk egy **.gitignore** nevű fájlt. Ez egy rejtett fájl lesz, ezért van előtte egy pont. 

    venv/
    __pycache__/
    db.sqlite3
    dockerignore

Rakjuk bele ezeket a fájlokat, hogy a git figyelmen kívül hagyja és ne legyen ebből gond a későbbiekben a GitHub-on.

A következő lépésünk, hogy a **pip freeze** segítségével létrehozunk egy szöveges állományt:

    pip freeze > requirements.txt

Ez létrehozza a követelmények fájlt. 

    asgiref==3.10.0
    Django==5.2.7
    sqlparse==0.5.3

Ide azonban be kell venni egy fontos szereplőt a **gunicorn** nevűt. Azért, mert ha ez hiányzik, akkor nem fog normálisan működni a Docker.

    asgiref==3.10.0
    Django==5.2.7
    sqlparse==0.5.3
    gunicorn

Most még nem töltjük fel az anyagot a GitHubra, pedig fel lehetne így is, de nem ez a célunk, hanem az, hogy a Dockerbe csomagoljuk a Django appunkat.

Deaktiváljuk a virtuális környezetünket:

    (venv) $ deactivate
    $

Maradjunk a docker_django könyvtárban, már nem müködik a virtuális környezet és neki láthatunk a Docker fájl elkészítésének.
Ehhez hozzunk létre egy üres fájlt, aminek az lesz a neve, hogy **Dockerfile** minden fájlkiterjesztés nélkül és nagy kezdőbetűvel. 

**Dockerfile**

    # 1. Az alap image
    FROM python:3.11-slim
    
    # 2. Környezeti változók 
    ENV PYTHONUNBUFFERED 1
    ENV DJANGO_PROJECT_NAME docker_django
    ENV PORT 8000
    
    # 3. Munkakönyvtár létrehozása és beállítása a konténerben
    WORKDIR /usr/src/app
   
    # 4. Függőségek másolása és telepítése    
    COPY requirements.txt .
    RUN pip install --no-cache-dir -r requirements.txt
    
    # 5. A teljes projektkód másolása a munkakönyvtárba
    COPY . .
    
    # 6. A port megnyitása
    EXPOSE 8000
    
    # 7. Konténer indítási parancsa, a Gunicorn futtatja a Django projektet a wsgi.py fájlon keresztül.
    # Az 'exampe.wsgi:application' helyére a fő projektkönyvtárad nevét írd be.
    # Ebben az esetben a docker_django a neve.
    CMD ["gunicorn", "--bind", "0.0.0.0:8000", "docker_django.wsgi:application"]

Mentsük el a Dockerfile tartalmát és adjuk ki a következő paranbccot: 

    docker build -t django-app:latest .

Futtasuk a Docker konténert:

    docker run -d -p 80:8000 --name my-django-container django-app:latest

A **http://localhost:80** porton elérhető lesz az alkalmazás.

De mi van, ha hibát ad a Docker?

Merthogy ez szinte biztosan előfordul, miért is működne minden rendben. Ebben az esetben a következőt kell tenni:

1. Le kell állítanod a konténer futását.
2. Le kell törölnöd a meglévő nevet.

Ellenőrizd, hogy fut-e a konténered:

    docker ps 

Ha fut és bizony futni fog a háttérben, akkor le kell állítani.

    docker stop my-django-container

Ennek le kell állítania a folyamatot. A terminálban ki fogja írni, hogy **my-django-container**, vagyis sikeresen leállítottad.

Ezután töröld a meglévő nevet:

    docker rm my-django-container

A kimenetben ismét a **my-django-container** fog megjelenni. Ha ismét törlöd, akkor pedig egy hiba üzenetet fogsz kapni: **Error: No such container: my-django-container**, vagyis nem létezik ezen a néven konténer.

A lényeg, hogy most már lehet indítani a Docker-t a fentebb leírt docker run paranccsal. Közben ellenőrizheted a futását és végül leállíthatod.

De nem árt egy ellenőrzés, hogy minden rendben van-e a konténerrel:

    docker logs my-django-container

A **docker_django** konfigurációs könyvtárunkban létre kell hoznunk egy **.dockerignore** nevű fájlt. Ez nem kötelező, de erősen ajánlott. 

Hozzunk létre egy üres fájlt a következő tartalommal:

    venv
    .git
    .gitignore

Ezzel készen vagyunk a Docker részével. Ezt most fel kell töltenünk a GitHub-ra. A feltöltés előtt ellenőrizni kell a fájlokat. A **git status** paranccsal ellenőrizzük a fájljainkat. Ha időközben módosítottunk valamit, akkor el kell végezni a szükséges beavatkozást.

    git add -A

Ezután kell egy commit művelet. 

    git commit -m "initial commit"

A távoli elérés esetében több lehetőség közül lehet választani. Az általam használt példa repository-ben az SSH megoldást használtam.  

    git remote add origin git@github.com:ZoltanBago/docker-django-repository.git

Ezután a következő két paranccsal lehet feltölteni: 

    git branch -M main
    git push -u origin main
    
Ebben az esetben kérni fogja az SSH jelszavad és utána feltölti a fájlokat a létrehozott GitHub repódba. 

De mi történik, ha hibát ír ki a terminál? Előfordulhat, hogy **reject** hibát kapunk. Ez azért alakul ki, mert a helyi main és a távoli main águnk nincsen összhangban egymással. 

Ezt az ellentmondást úgy oldhatjuk fel, ha úgymond újraalapozzuk a repónkat. Erre a **--rebase** a megoldás. 

    git pull origin main --rebase

A folyamat végén ezt kell, hogy megjelenítse a terminál:

    ...
    Successfully rebased and updated refs/heads/main.

Ezzel befejeződött az újraalapozás. Ismét meg kell adni a fentebb megadott git branch és a git push parancsokat.

Ha frissitjük a GitHub oldalunkat, akkor láthatjuk, hogy fenn vannak a Django projektünk fájljai. 
## Licenc

Ez a projekt a [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/) licenc alatt érhető el.  

Szabadon másolható, tanulmányozható és módosítható **nem kereskedelmi célra**, a szerző (Bagó Zoltán) nevének feltüntetése mellett.

Kereskedelmi felhasználás esetén külön engedély szükséges.

