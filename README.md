<div align="center">

![Introduction Banner](/public/banner.png)
# Spark IO - A Blogging Site
</div>

## Overview

 **Spark io** is a web application designed for blogging and user interactions. It allows users to create, edit, and manage blogs while enabling comments and likes. The platform includes an admin panel for managing users and content.

## Features

- **🛡 User Authentication**: Sign up, log in.
- **📝 Blog Management**: Create, edit, and delete blog posts.
- **💬 User Interaction**: Like and comment on blogs.
- **📊 Admin Dashboard**: Manage users and monitor activity.
- **📈 Analytics & Activity Tracking**: Admins can view user activity and blog performance using **Chart.js**.
  - View user engagement metrics.
  - Track blog post performance.
  - Visualize activity trends with interactive charts.
- **🎨 Responsive Design**: Works on both desktop and mobile.

## Tech Stack

- **🚀 Backend**: Ruby on Rails
- **🌐 Frontend**: HTML, CSS (Bootstrap), JavaScript.
- **🗄 Database**: PostgreSQL
- **🔐 Authentication**:  Custom JWT Based Authentication
- **🔏 Authorization**: Pundit
- **📊 Charts & Analytics**: Chart.js

## Schema Design
![Database Schema](/public/er-diagram.png)


## Installation & Setup
1. Clone the repository:
   ```sh
   git clone https://github.com/prajwal-gadhave-selldo/spark.io.git
   cd spark.io
   ```
2. Install dependencies:
   ```sh
   bundle install
   ```
3. Setup the database:
   ```sh
   rails db:migrate
   ```
4. Start the server:
   ```sh
   rails server
   ```
5. Open the application in your browser:
   ```sh
   http://localhost:3000
   ```

## Usage

- Create and manage blog posts.
- Sign up or log in to access the platform.
- Engage with content through comments and likes.
- Admin users can oversee activity and manage users.
- View **analytics and user activity** in the admin dashboard using **Chart.js**.
  - Interactive charts display engagement trends.
  - Performance metrics help in decision-making.

## Screenshots

<div align="center">
   <table>
   <tr>
      <td><img src="/public/1.png" width="400"></td>
      <td><img src="/public/2.png" width="400"></td>
   </tr>
   <tr>
      <td><img src="/public/3.png" width="400"></td>
      <td><img src="/public/6.png" width="400"></td>
   </tr>
   <tr>
      <td><img src="/public/7.png" width="400"></td>
      <td><img src="/public/8.png" width="400"></td>
   </tr>
   <tr>
      <td><img src="/public/5.png" width="400"></td>
      <td><img src="/public/4.png" width="400"></td>
   </tr>
   </table>
</div>