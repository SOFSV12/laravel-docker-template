# Setup Instructions
>  In order to run this project succesfully on your host machine please ensure you have [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed locally. 
> Upon completion please follow remianing instructiions;

## URL's
   - APP_URL = http://127.0.0.1:8080
   - DATABASE_URL = http://127.0.0.1:5050
   - LARAVEL_HORIZON_URL = http://127.0.0.1:8080/horizon

 
## 1. Start the Docker containers
      docker compose up --build -d
## 2. Install PHP dependencies on Host Machine
      composer install --ignore-platform-reqs
## 3. Configure environment variables
      cp .env.example .env
      php artisan key:generate
## 4. Run Database Migrations
      php artisan migrate  
## 5. Accessing Database 
>To visit database [Database](http://127.0.0.1:5050)  Credentials can be found in docker-compose.yml 
    POSTGRES_USER: bayana
    POSTGRES_PASSWORD: causes101  
### To connect via the interface
1. Click **Add New Server**  
2. Enter the following details:
   - **Host Name / Address:** `db`
   - **Username:** `bayana`
   - **Password:** `causes101`
3. Save and connect 





