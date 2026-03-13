# Construction Management API
# Construction Management API
**Developer:** Dhanshri Pravin Nemade
**Email:** 26dn2005@gmail.com
A REST API built with **Node.js (Express)** + **MySQL (Sequelize ORM)** for managing Users, Projects, and Daily Progress Reports (DPR).

---

## Tech Stack

| Layer | Technology | Why |
|-------|------------|-----|
| Runtime | Node.js | JavaScript on the server |
| Framework | Express.js | Minimal, fast HTTP server |
| Database | MySQL | Relational DB with foreign keys |
| ORM | Sequelize | Maps JS objects ↔ DB tables |
| Auth | JWT (jsonwebtoken) | Stateless token authentication |
| Password | bcryptjs | Secure password hashing |
| Validation | express-validator | Input validation middleware |

---

## Project Structure

```
construction-api/
├── server.js              ← Entry point: starts server, connects DB
├── config/
│   └── database.js        ← Sequelize connection setup
├── models/
│   ├── User.js            ← users table schema
│   ├── Project.js         ← projects table schema
│   ├── DailyReport.js     ← daily_reports table schema
│   └── index.js           ← Relationships (hasMany / belongsTo)
├── controllers/
│   ├── authController.js  ← register, login, getMe logic
│   ├── projectController.js ← CRUD logic for projects
│   └── dprController.js   ← create & list DPRs
├── routes/
│   ├── authRoutes.js      ← URL → controller mapping for /auth
│   ├── projectRoutes.js   ← URL → controller mapping for /projects
│   └── dprRoutes.js       ← URL → controller mapping for /dpr
├── middleware/
│   └── auth.js            ← JWT verify + role-based access control
├── schema.sql             ← Manual SQL script to create tables
├── .env.example           ← Required environment variables
└── ConstructionAPI.postman_collection.json
```

---

## Database Setup (MySQL)

### Option A — Let Sequelize auto-create tables (Recommended)
Just start the server. `sequelize.sync({ alter: true })` in `server.js` creates all tables automatically.

### Option B — Manual SQL script
```bash
# Login to MySQL
mysql -u root -p

# Run the schema file
mysql -u root -p < schema.sql
```

---

## Setup & Run

### 1. Clone the repo
```bash
git clone https://github.com/YOUR_USERNAME/construction-api.git
cd construction-api
```

### 2. Install dependencies
```bash
npm install
```

### 3. Configure environment
```bash
cp .env.example .env
# Edit .env and fill in your MySQL credentials
```

Your `.env` file should look like:
```
PORT=3000
DB_HOST=localhost
DB_PORT=3306
DB_NAME=construction_db
DB_USER=root
DB_PASSWORD=yourpassword
JWT_SECRET=anylongrandomstring
JWT_EXPIRES_IN=7d
```

### 4. Create MySQL database
```sql
CREATE DATABASE construction_db;
```

### 5. Start the server
```bash
# Development (auto-restart on file changes)
npm run dev

# Production
npm start
```

You should see:
```
✅ Database connected successfully
✅ Database tables synced
🚀 Server running on http://localhost:3000
```

---

## API Endpoints

### Authentication

| Method | URL | Auth | Role | Description |
|--------|-----|------|------|-------------|
| POST | /auth/register | No | - | Create new account |
| POST | /auth/login | No | - | Login, get JWT token |
| GET | /auth/me | Yes | Any | Get my profile |

### Projects

| Method | URL | Auth | Role | Description |
|--------|-----|------|------|-------------|
| POST | /projects | Yes | admin, manager | Create project |
| GET | /projects | Yes | Any | List all projects |
| GET | /projects/:id | Yes | Any | Get single project |
| PUT | /projects/:id | Yes | admin, manager | Update project |
| DELETE | /projects/:id | Yes | admin | Delete project |

### Daily Progress Reports

| Method | URL | Auth | Role | Description |
|--------|-----|------|------|-------------|
| POST | /projects/:id/dpr | Yes | Any | Submit DPR |
| GET | /projects/:id/dpr | Yes | Any | List DPRs |

---

## Example API Requests (curl)

### Register a user
```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "phone": "9876543210",
    "role": "admin"
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "User registered successfully",
  "userId": 1
}
```

---

### Login
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": { "id": 1, "name": "John Doe", "email": "john@example.com", "role": "admin" }
}
```

> **Copy the token!** Use it as `Bearer <token>` in all subsequent requests.

---

### Create a Project (admin/manager only)
```bash
curl -X POST http://localhost:3000/projects \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "name": "Highway Construction Phase 1",
    "description": "Building 10km highway stretch",
    "startDate": "2026-01-15",
    "endDate": "2026-12-31",
    "budget": 5000000,
    "location": "Pune, Maharashtra"
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Project created successfully",
  "projectId": 1
}
```

---

### Get All Projects (with pagination)
```bash
curl "http://localhost:3000/projects?status=active&limit=10&offset=0" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

### Submit a Daily Progress Report
```bash
curl -X POST http://localhost:3000/projects/1/dpr \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "date": "2026-03-13",
    "work_description": "Completed foundation for section A. Poured concrete for 200m.",
    "weather": "Sunny, 28°C",
    "worker_count": 45
  }'
```

---

### Get DPRs for a Project
```bash
# All DPRs
curl "http://localhost:3000/projects/1/dpr" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"

# Filter by date
curl "http://localhost:3000/projects/1/dpr?date=2026-03-13" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## HTTP Status Codes Used

| Code | Meaning | When |
|------|---------|------|
| 200 | OK | Successful GET, PUT |
| 201 | Created | Successful POST (new resource created) |
| 400 | Bad Request | Validation error / missing fields |
| 401 | Unauthorized | No token / invalid token |
| 403 | Forbidden | Valid token but wrong role |
| 404 | Not Found | Resource doesn't exist |
| 500 | Internal Server Error | Unexpected server error |

---

## Database Schema & Relationships

```
users (1) ──────────────< projects (many)
  id PK                    id PK
  name                     name
  email UNIQUE             description
  password_hash            start_date
  role ENUM                end_date
  created_at               status ENUM
                           budget
                           location
                           created_by FK → users.id
                           created_at

projects (1) ───────────< daily_reports (many)
                           id PK
users (1) ──────────────< project_id FK → projects.id
                           user_id FK → users.id
                           date
                           work_description
                           weather
                           worker_count
                           created_at
```

---

## Authentication Flow

1. Client sends `POST /auth/register` with name, email, password
2. Server hashes password with bcrypt (10 rounds), saves to DB
3. Client sends `POST /auth/login` with email, password
4. Server finds user by email, compares password with bcrypt.compare()
5. Server generates JWT: `jwt.sign({ id: user.id }, JWT_SECRET, { expiresIn: '7d' })`
6. Client receives token, stores it (localStorage / memory)
7. Client sends token in header: `Authorization: Bearer <token>`
8. Server middleware (`authenticate`) verifies token with `jwt.verify()`
9. If valid → attaches user to `req.user` and calls `next()`
10. Role check (`authorize`) → checks `req.user.role` against allowed roles

---

## Testing with Postman

1. Import `ConstructionAPI.postman_collection.json` into Postman
2. The collection has a variable `{{baseUrl}}` = `http://localhost:3000`
3. Run **Register User** first, then **Login** — token auto-saves to `{{token}}`
4. All other requests use `{{token}}` automatically in Authorization header
5. Update `{{projectId}}` variable after creating a project
