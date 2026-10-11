```jsp
<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Locale"%>
<%@ page import="com.tap.module.User"%>

<%
    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/Login.jsp");
        return;
    }

    String currentRole = String.valueOf(session.getAttribute("role"));
    if (!"ADMIN".equalsIgnoreCase(currentRole)) {
        response.sendRedirect(request.getContextPath() + "/restaurent");
        return;
    }

    String adminUsername = String.valueOf(session.getAttribute("username"));
    if ("null".equals(adminUsername) || adminUsername.trim().isEmpty()) {
        adminUsername = "Administrator";
    }

    String currentUserId = String.valueOf(session.getAttribute("userId"));

    List<User> users = (List<User>) request.getAttribute("users");

    Integer totalValue = (Integer) request.getAttribute("totalUsers");
    Integer adminsValue = (Integer) request.getAttribute("adminUsers");
    Integer customersValue = (Integer) request.getAttribute("customerUsers");

    int totalUsers = totalValue == null ? 0 : totalValue;
    int adminUsers = adminsValue == null ? 0 : adminsValue;
    int customerUsers = customersValue == null ? 0 : customersValue;
    int displayedUsers = users == null ? 0 : users.size();

    String search = (String) request.getAttribute("search");
    if (search == null) search = "";

    String roleFilter = (String) request.getAttribute("roleFilter");
    if (roleFilter == null || roleFilter.trim().isEmpty()) roleFilter = "ALL";
    roleFilter = roleFilter.trim().toUpperCase(Locale.ROOT);

    if (!"ALL".equals(roleFilter) &&
        !"ADMIN".equals(roleFilter) &&
        !"USER".equals(roleFilter)) {
        roleFilter = "ALL";
    }

    String userError = (String) request.getAttribute("userError");

    String result = request.getParameter("updated");
    String errorCode = request.getParameter("error");

    java.util.function.Function<String, String> esc = value -> {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    };

    String safeAdminUsername = esc.apply(adminUsername);
    String adminInitial = esc.apply(
        adminUsername.trim().substring(0, 1).toUpperCase(Locale.ROOT)
    );
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Foodwala | User Management</title>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Poppins:wght@500;600;700;800&display=swap" rel="stylesheet">

<style>
*{box-sizing:border-box;margin:0;padding:0}
:root{
 --bg:#09090b;--surface:#111114;--surface2:#151519;--card:#18181c;
 --orange:#ff6b35;--orangeDark:#e95727;--orangeSoft:rgba(255,107,53,.11);
 --gold:#ffb45c;--text:#f7f7f8;--soft:#d4d4d8;--muted:#a1a1aa;
 --muted2:#71717a;--border:#29292f;--green:#22c55e;
 --red:#ef4444;--redSoft:rgba(239,68,68,.10);--radius:17px
}
body{min-height:100vh;background:radial-gradient(circle at 85% 0%,rgba(255,107,53,.09),transparent 28%),var(--bg);color:var(--text);font-family:Inter,Arial,sans-serif}
a{color:inherit;text-decoration:none}
button,input,select,textarea{font:inherit}
button:focus-visible,a:focus-visible,input:focus-visible,select:focus-visible,textarea:focus-visible{outline:2px solid var(--orange);outline-offset:3px}
.navbar{position:sticky;top:0;z-index:10;min-height:70px;display:flex;align-items:center;justify-content:space-between;gap:14px;padding:0 30px;background:rgba(9,9,11,.96);border-bottom:1px solid var(--border);backdrop-filter:blur(15px)}
.brand{display:flex;align-items:center;gap:10px}
.brand-mark{width:39px;height:39px;display:grid;place-items:center;border-radius:11px;background:linear-gradient(135deg,var(--orange),var(--gold));color:#111;font-family:Poppins,sans-serif;font-weight:800}
.brand-name{font-family:Poppins,sans-serif;font-size:21px;font-weight:800}
.admin-label{padding:5px 8px;border-radius:7px;color:var(--orange);background:var(--orangeSoft);font-size:9px;font-weight:800;letter-spacing:1px}
.nav-right{display:flex;align-items:center;gap:10px}
.dashboard-btn{padding:11px 13px;border:1px solid var(--border);border-radius:10px;color:var(--muted);font-size:12px;font-weight:700}
.dashboard-btn:hover{color:var(--text);background:var(--card)}
.admin-user{display:flex;align-items:center;gap:9px;padding:5px 10px 5px 5px;border:1px solid var(--border);border-radius:11px;background:var(--surface)}
.admin-avatar{width:31px;height:31px;display:grid;place-items:center;border-radius:9px;color:var(--orange);background:var(--orangeSoft);font-weight:800}
.admin-name{max-width:150px;overflow:hidden;color:var(--soft);font-size:12px;white-space:nowrap;text-overflow:ellipsis}
.page{width:min(1450px,calc(100% - 40px));margin:auto;padding:35px 0 60px}
.page-header{display:flex;align-items:flex-end;justify-content:space-between;gap:18px;margin-bottom:24px}
.eyebrow{margin-bottom:8px;color:var(--orange);font-size:10px;font-weight:800;letter-spacing:1.8px;text-transform:uppercase}
h1{font-family:Poppins,sans-serif;font-size:clamp(28px,4vw,40px);line-height:1.15;letter-spacing:-1px}
.subtitle{margin-top:9px;color:var(--muted);font-size:13px;line-height:1.65}
.btn{display:inline-flex;align-items:center;justify-content:center;gap:7px;min-height:39px;padding:0 13px;border:1px solid var(--border);border-radius:10px;background:var(--surface);color:var(--soft);font-size:11px;font-weight:800;cursor:pointer;transition:.2s}
.btn:hover{transform:translateY(-1px);border-color:#444}
.btn-primary{border-color:var(--orange);background:var(--orange);color:#111}
.btn-primary:hover{background:var(--orangeDark)}
.btn-danger{border-color:rgba(239,68,68,.25);background:var(--redSoft);color:#fca5a5}
.btn-danger:hover{background:rgba(239,68,68,.18)}
.btn-small{min-height:32px;padding:0 10px;font-size:10px}
.stats{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:14px;margin-bottom:20px}
.stat{padding:19px;border:1px solid var(--border);border-radius:var(--radius);background:linear-gradient(145deg,rgba(255,255,255,.025),transparent),var(--card)}
.stat-label{color:var(--muted);font-size:11px;font-weight:600}
.stat-value{margin-top:10px;font-family:Poppins,sans-serif;font-size:29px;font-weight:700}
.stat-description{margin-top:3px;color:var(--muted2);font-size:10px}
.main-card{overflow:hidden;border:1px solid var(--border);border-radius:var(--radius);background:var(--card)}
.card-header{display:flex;align-items:center;justify-content:space-between;gap:12px;padding:19px 22px;border-bottom:1px solid var(--border)}
.section-title{font-family:Poppins,sans-serif;font-size:17px;font-weight:700}
.count{margin-left:7px;padding:4px 8px;border-radius:7px;background:var(--surface);color:var(--muted);font-size:10px}
.filters{display:flex;align-items:center;gap:9px;padding:15px 22px;border-bottom:1px solid var(--border)}
.search{flex:1;min-width:0}
.control,.search input,.role-select{width:100%;min-height:42px;padding:10px 12px;border:1px solid var(--border);border-radius:10px;background:var(--surface);color:var(--text);font-size:12px}
.search input{height:42px}
.control::placeholder,.search input::placeholder{color:var(--muted2)}
.role-select{width:auto;min-width:145px}
.role-select option{background:#fff;color:#111}
.alert{margin:16px 22px 0;padding:12px 14px;border-radius:10px;font-size:12px;line-height:1.55}
.alert-error{border:1px solid rgba(239,68,68,.25);background:var(--redSoft);color:#fecaca}
.alert-success{border:1px solid rgba(34,197,94,.25);background:rgba(34,197,94,.09);color:#bbf7d0}
.table-wrap{overflow-x:auto}
table{width:100%;min-width:950px;border-collapse:collapse}
thead{background:#141418}
th{padding:13px 16px;color:var(--muted2);font-size:9px;font-weight:800;letter-spacing:.8px;text-align:left;text-transform:uppercase;white-space:nowrap}
td{padding:15px 16px;border-top:1px solid rgba(255,255,255,.055);vertical-align:middle;font-size:11px}
tbody tr:hover{background:rgba(255,255,255,.018)}
.user-cell{display:flex;align-items:center;gap:10px;min-width:150px}
.user-avatar{width:39px;height:39px;flex-shrink:0;display:grid;place-items:center;border:1px solid rgba(255,107,53,.15);border-radius:11px;background:var(--orangeSoft);color:var(--orange);font-weight:800}
.user-name{font-size:12px;font-weight:700;overflow-wrap:anywhere}
.user-id{margin-top:4px;color:var(--muted2);font-size:9px}
.wrap-text{max-width:200px;color:var(--soft);overflow-wrap:anywhere;line-height:1.5}
.role-badge{display:inline-flex;padding:6px 8px;border-radius:7px;font-size:9px;font-weight:800;white-space:nowrap}
.role-admin{color:#fdba74;background:rgba(249,115,22,.10)}
.role-user{color:#86efac;background:rgba(34,197,94,.10)}
.actions{display:flex;gap:6px;align-items:center;flex-wrap:wrap}
.inline-form{display:inline}
.mobile-users{display:none;padding:13px}
.mobile-user{margin-bottom:12px;padding:15px;border:1px solid var(--border);border-radius:14px;background:var(--surface)}
.mobile-top{display:flex;justify-content:space-between;align-items:center;gap:10px;margin-bottom:13px}
.mobile-person{display:flex;align-items:center;gap:10px;min-width:0}
.mobile-name{font-size:12px;font-weight:700;overflow-wrap:anywhere}
.mobile-details{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:8px}
.detail{min-width:0;padding:10px;border-radius:9px;background:#151519}
.detail-label{margin-bottom:5px;color:var(--muted2);font-size:8px;font-weight:800;text-transform:uppercase}
.detail-value{font-size:10px;color:var(--soft);overflow-wrap:anywhere;line-height:1.5}
.mobile-actions{display:flex;gap:7px;margin-top:12px;flex-wrap:wrap}
.empty{padding:55px 20px;text-align:center}
.empty-title{font-family:Poppins,sans-serif;font-size:17px;font-weight:700}
.empty p{margin:8px auto 0;max-width:440px;color:var(--muted);font-size:12px;line-height:1.6}
.footer{margin-top:23px;color:var(--muted2);text-align:center;font-size:10px}

/* Forms */
.form-panel{margin:18px 22px;padding:20px;border:1px solid var(--border);border-radius:13px;background:var(--surface)}
.form-panel h3{margin-bottom:15px;font-family:Poppins,sans-serif;font-size:15px}
.form-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:13px}
.field{display:flex;flex-direction:column;gap:7px;min-width:0}
.field label{color:var(--muted);font-size:10px;font-weight:700}
.field input,.field select,.field textarea{width:100%;min-height:41px;padding:10px 11px;border:1px solid var(--border);border-radius:9px;background:#0d0d10;color:var(--text);font-size:12px}
.field textarea{min-height:76px;resize:vertical}
.field select option{background:#fff;color:#111}
.field-full{grid-column:1/-1}
.form-actions{display:flex;gap:8px;flex-wrap:wrap;margin-top:15px}
.help{color:var(--muted2);font-size:10px;line-height:1.5}
details.edit-details{margin-top:9px}
details.edit-details summary{width:max-content;list-style:none;cursor:pointer}
details.edit-details summary::-webkit-details-marker{display:none}
details.edit-details[open] summary{margin-bottom:10px}
.edit-form{min-width:230px;padding:13px;border:1px solid var(--border);border-radius:10px;background:#101014}
.edit-form .field{margin-bottom:10px}
.delete-note{color:var(--muted2);font-size:10px;line-height:1.5}
@media(max-width:950px){.navbar{padding:0 18px}.admin-name{display:none}.page{width:calc(100% - 28px)}}
@media(max-width:720px){
 .navbar{min-height:63px;padding:0 12px}.brand-name{font-size:18px}.brand-mark{width:35px;height:35px}.admin-label,.dashboard-btn{display:none}
 .page{width:calc(100% - 20px);padding-top:24px}.page-header{align-items:flex-start;flex-direction:column}
 .stats{grid-template-columns:1fr;gap:8px}.stat{padding:15px}.stat-value{font-size:25px}
 .card-header{padding:15px}.filters{display:grid;grid-template-columns:1fr 1fr;padding:12px;gap:8px}
 .search{grid-column:1/-1}.role-select{width:100%;min-width:0}.filters .btn,.filters .clear-btn{width:100%}
 .table-wrap{display:none}.mobile-users{display:block}.form-panel{margin:12px;padding:14px}
 .form-grid{grid-template-columns:1fr}.field-full{grid-column:auto}
}
@media(max-width:420px){.mobile-details{grid-template-columns:1fr}.filters{grid-template-columns:1fr}.search{grid-column:auto}.mobile-top{align-items:flex-start}}
@media(prefers-reduced-motion:reduce){*{scroll-behavior:auto!important;transition:none!important}}
</style>
</head>

<body>
<header class="navbar">
    <a href="<%= request.getContextPath() %>/adminDashboard" class="brand">
        <div class="brand-mark">F</div>
        <div class="brand-name">Foodwala</div>
        <span class="admin-label">ADMIN</span>
    </a>
    <div class="nav-right">
        <a href="<%= request.getContextPath() %>/adminDashboard" class="dashboard-btn">&#8592; Dashboard</a>
        <div class="admin-user">
            <div class="admin-avatar"><%= adminInitial %></div>
            <div class="admin-name"><%= safeAdminUsername %></div>
        </div>
    </div>
</header>

<main class="page">
    <section class="page-header">
        <div>
            <div class="eyebrow">Administration</div>
            <h1>User Management</h1>
            <p class="subtitle">Manage Foodwala accounts, update user details, assign roles, and search your user base.</p>
        </div>
    </section>

    <% if ("1".equals(result)) { %>
        <div class="alert alert-success" role="status">User operation completed successfully.</div>
    <% } else if ("invalid".equals(errorCode)) { %>
        <div class="alert alert-error" role="alert">The request could not be completed. Check the user details and make sure you are not modifying your own administrator account.</div>
    <% } else if ("operation".equals(errorCode)) { %>
        <div class="alert alert-error" role="alert">The operation failed. The user may be linked to existing records, or the database rejected the change. Check your server console for details.</div>
    <% } %>

    <% if (userError != null && !userError.trim().isEmpty()) { %>
        <div class="alert alert-error" role="alert"><%= esc.apply(userError) %></div>
    <% } %>

    <section class="stats">
        <div class="stat">
            <div class="stat-label">Total Users</div>
            <div class="stat-value"><%= totalUsers %></div>
            <div class="stat-description">Registered accounts</div>
        </div>
        <div class="stat">
            <div class="stat-label">Administrators</div>
            <div class="stat-value"><%= adminUsers %></div>
            <div class="stat-description">Admin accounts</div>
        </div>
        <div class="stat">
            <div class="stat-label">Customers</div>
            <div class="stat-value"><%= customerUsers %></div>
            <div class="stat-description">Customer accounts</div>
        </div>
    </section>

    <section class="main-card">
        <div class="card-header">
            <div>
                <span class="section-title">All Users</span>
                <span class="count"><%= displayedUsers %> shown</span>
            </div>
            <a class="btn btn-primary" href="#add-user">+ Add User</a>
        </div>

        <form class="filters" method="get" action="<%= request.getContextPath() %>/adminUsers">
            <div class="search">
                <input type="text" name="search" value="<%= esc.apply(search) %>"
                       placeholder="Search username, email, phone or ID"
                       aria-label="Search users" autocomplete="off">
            </div>
            <select name="role" class="role-select" aria-label="Filter users by role">
                <option value="ALL" <%= "ALL".equals(roleFilter) ? "selected" : "" %>>All Roles</option>
                <option value="ADMIN" <%= "ADMIN".equals(roleFilter) ? "selected" : "" %>>Administrators</option>
                <option value="USER" <%= "USER".equals(roleFilter) ? "selected" : "" %>>Customers</option>
            </select>
            <button type="submit" class="btn btn-primary">Search</button>
            <a href="<%= request.getContextPath() %>/adminUsers" class="btn">Clear</a>
        </form>

        <!-- ADD USER -->
        <section class="form-panel" id="add-user">
            <h3>Add a User</h3>
            <form method="post" action="<%= request.getContextPath() %>/adminUsers" autocomplete="off">
                <input type="hidden" name="action" value="add">
                <div class="form-grid">
                    <div class="field">
                        <label for="addUsername">Username *</label>
                        <input id="addUsername" name="username" type="text" maxlength="100" required>
                    </div>
                    <div class="field">
                        <label for="addPassword">Password *</label>
                        <input id="addPassword" name="password" type="password" minlength="8" maxlength="200" required>
                        <span class="help">Use at least 8 characters.</span>
                    </div>
                    <div class="field">
                        <label for="addEmail">Email</label>
                        <input id="addEmail" name="email" type="email" maxlength="254">
                    </div>
                    <div class="field">
                        <label for="addPhone">Phone</label>
                        <input id="addPhone" name="phone" type="tel" maxlength="30">
                    </div>
                    <div class="field field-full">
                        <label for="addAddress">Address</label>
                        <textarea id="addAddress" name="address" maxlength="1000"></textarea>
                    </div>
                    <div class="field">
                        <label for="addRole">Role *</label>
                        <select id="addRole" name="role" required>
                            <option value="USER">USER — Customer</option>
                            <option value="ADMIN">ADMIN — Administrator</option>
                        </select>
                    </div>
                </div>
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Create User</button>
                    <button type="reset" class="btn">Clear Form</button>
                </div>
            </form>
        </section>

        <% if (users != null && !users.isEmpty()) { %>
            <!-- DESKTOP USER TABLE -->
            <div class="table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>User</th><th>Email</th><th>Phone</th><th>Address</th><th>Role</th><th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% for (User user : users) {
                        if (user == null) continue;

                        String username = user.getUsername();
                        if (username == null || username.trim().isEmpty()) username = "Unknown User";

                        String email = user.getEmail();
                        if (email == null || email.trim().isEmpty()) email = "Not provided";

                        String phone = user.getPhone();
                        if (phone == null || phone.trim().isEmpty()) phone = "Not provided";

                        String address = user.getAddress();
                        if (address == null || address.trim().isEmpty()) address = "Not provided";

                        String userRole = user.getRole();
                        if (userRole == null || userRole.trim().isEmpty()) userRole = "USER";

                        String initial = username.trim().substring(0,1).toUpperCase(Locale.ROOT);
                        boolean isAdmin = "ADMIN".equalsIgnoreCase(userRole.trim());
                        String roleClass = isAdmin ? "role-admin" : "role-user";
                        boolean isSelf = currentUserId.equals(String.valueOf(user.getUserId()));
                    %>
                        <tr>
                            <td>
                                <div class="user-cell">
                                    <div class="user-avatar"><%= esc.apply(initial) %></div>
                                    <div>
                                        <div class="user-name"><%= esc.apply(username) %></div>
                                        <div class="user-id">User ID: <%= user.getUserId() %></div>
                                    </div>
                                </div>
                            </td>
                            <td><div class="wrap-text"><%= esc.apply(email) %></div></td>
                            <td><div class="wrap-text"><%= esc.apply(phone) %></div></td>
                            <td><div class="wrap-text"><%= esc.apply(address) %></div></td>
                            <td><span class="role-badge <%= roleClass %>"><%= esc.apply(userRole.toUpperCase(Locale.ROOT)) %></span></td>
                            <td>
                                <% if (isSelf) { %>
                                    <span class="help">Current account</span>
                                <% } else { %>
                                    <div class="actions">
                                        <details class="edit-details">
                                            <summary class="btn btn-small">Edit</summary>
                                            <form class="edit-form" method="post" action="<%= request.getContextPath() %>/adminUsers" autocomplete="off">
                                                <input type="hidden" name="action" value="update">
                                                <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                                                <div class="field">
                                                    <label>Username *</label>
                                                    <input name="username" type="text" maxlength="100" value="<%= esc.apply(username.equals("Unknown User") ? "" : username) %>" required>
                                                </div>
                                                <div class="field">
                                                    <label>New Password</label>
                                                    <input name="password" type="password" minlength="8" maxlength="200" autocomplete="new-password">
                                                    <span class="help">Leave blank to keep current password.</span>
                                                </div>
                                                <div class="field">
                                                    <label>Email</label>
                                                    <input name="email" type="email" maxlength="254" value="<%= esc.apply(email.equals("Not provided") ? "" : email) %>">
                                                </div>
                                                <div class="field">
                                                    <label>Phone</label>
                                                    <input name="phone" type="tel" maxlength="30" value="<%= esc.apply(phone.equals("Not provided") ? "" : phone) %>">
                                                </div>
                                                <div class="field">
                                                    <label>Address</label>
                                                    <textarea name="address" maxlength="1000"><%= esc.apply(address.equals("Not provided") ? "" : address) %></textarea>
                                                </div>
                                                <div class="field">
                                                    <label>Role *</label>
                                                    <select name="role" required>
                                                        <option value="USER" <%= "USER".equalsIgnoreCase(userRole) ? "selected" : "" %>>USER</option>
                                                        <option value="ADMIN" <%= "ADMIN".equalsIgnoreCase(userRole) ? "selected" : "" %>>ADMIN</option>
                                                    </select>
                                                </div>
                                                <button class="btn btn-primary btn-small" type="submit">Save Changes</button>
                                            </form>
                                        </details>
                                        <form class="inline-form" method="post" action="<%= request.getContextPath() %>/adminUsers"
                                              onsubmit="return confirm('Delete user <%= esc.apply(username).replace("\\", "\\\\").replace("'", "\\'") %>? This action cannot be undone.');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                                            <button class="btn btn-danger btn-small" type="submit">Delete</button>
                                        </form>
                                    </div>
                                <% } %>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>

            <!-- MOBILE USER CARDS -->
            <div class="mobile-users">
                <% for (User user : users) {
                    if (user == null) continue;

                    String username = user.getUsername();
                    if (username == null || username.trim().isEmpty()) username = "Unknown User";

                    String email = user.getEmail();
                    if (email == null || email.trim().isEmpty()) email = "Not provided";

                    String phone = user.getPhone();
                    if (phone == null || phone.trim().isEmpty()) phone = "Not provided";

                    String address = user.getAddress();
                    if (address == null || address.trim().isEmpty()) address = "Not provided";

                    String userRole = user.getRole();
                    if (userRole == null || userRole.trim().isEmpty()) userRole = "USER";

                    String initial = username.trim().substring(0,1).toUpperCase(Locale.ROOT);
                    boolean isAdmin = "ADMIN".equalsIgnoreCase(userRole.trim());
                    boolean isSelf = currentUserId.equals(String.valueOf(user.getUserId()));
                %>
                    <article class="mobile-user">
                        <div class="mobile-top">
                            <div class="mobile-person">
                                <div class="user-avatar"><%= esc.apply(initial) %></div>
                                <div>
                                    <div class="mobile-name"><%= esc.apply(username) %></div>
                                    <div class="user-id">User ID: <%= user.getUserId() %></div>
                                </div>
                            </div>
                            <span class="role-badge <%= isAdmin ? "role-admin" : "role-user" %>"><%= esc.apply(userRole.toUpperCase(Locale.ROOT)) %></span>
                        </div>
                        <div class="mobile-details">
                            <div class="detail"><div class="detail-label">Email</div><div class="detail-value"><%= esc.apply(email) %></div></div>
                            <div class="detail"><div class="detail-label">Phone</div><div class="detail-value"><%= esc.apply(phone) %></div></div>
                            <div class="detail" style="grid-column:1/-1"><div class="detail-label">Address</div><div class="detail-value"><%= esc.apply(address) %></div></div>
                        </div>

                        <% if (isSelf) { %>
                            <p class="help" style="margin-top:12px">This is your current administrator account. Use another admin account to modify it.</p>
                        <% } else { %>
                            <div class="mobile-actions">
                                <details class="edit-details">
                                    <summary class="btn btn-small">Edit User</summary>
                                    <form class="edit-form" method="post" action="<%= request.getContextPath() %>/adminUsers" autocomplete="off">
                                        <input type="hidden" name="action" value="update">
                                        <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                                        <div class="field">
                                            <label>Username *</label>
                                            <input name="username" maxlength="100" value="<%= esc.apply(username.equals("Unknown User") ? "" : username) %>" required>
                                        </div>
                                        <div class="field">
                                            <label>New Password</label>
                                            <input name="password" type="password" minlength="8" maxlength="200" autocomplete="new-password">
                                            <span class="help">Leave blank to keep current password.</span>
                                        </div>
                                        <div class="field">
                                            <label>Email</label>
                                            <input name="email" type="email" maxlength="254" value="<%= esc.apply(email.equals("Not provided") ? "" : email) %>">
                                        </div>
                                        <div class="field">
                                            <label>Phone</label>
                                            <input name="phone" type="tel" maxlength="30" value="<%= esc.apply(phone.equals("Not provided") ? "" : phone) %>">
                                        </div>
                                        <div class="field">
                                            <label>Address</label>
                                            <textarea name="address" maxlength="1000"><%= esc.apply(address.equals("Not provided") ? "" : address) %></textarea>
                                        </div>
                                        <div class="field">
                                            <label>Role *</label>
                                            <select name="role" required>
                                                <option value="USER" <%= "USER".equalsIgnoreCase(userRole) ? "selected" : "" %>>USER</option>
                                                <option value="ADMIN" <%= "ADMIN".equalsIgnoreCase(userRole) ? "selected" : "" %>>ADMIN</option>
                                            </select>
                                        </div>
                                        <button class="btn btn-primary btn-small" type="submit">Save Changes</button>
                                    </form>
                                </details>

                                <form class="inline-form" method="post" action="<%= request.getContextPath() %>/adminUsers"
                                      onsubmit="return confirm('Delete this user? This action cannot be undone.');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                                    <button class="btn btn-danger btn-small" type="submit">Delete User</button>
                                </form>
                            </div>
                        <% } %>
                    </article>
                <% } %>
            </div>

        <% } else { %>
            <div class="empty">
                <div class="empty-title">No users found</div>
                <p>
                    <% if (!search.isEmpty() || !"ALL".equals(roleFilter)) { %>
                        No users match the current search or role filter. Try changing your search criteria.
                    <% } else if (userError == null || userError.trim().isEmpty()) { %>
                        There are currently no users available to display. You can add a user using the form above.
                    <% } else { %>
                        User information could not be loaded. Please try again.
                    <% } %>
                </p>
            </div>
        <% } %>
    </section>

    <div class="footer">Foodwala Administration &nbsp;&bull;&nbsp; User Management</div>
</main>
</body>
</html>
```