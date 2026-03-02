<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String userId     = (String) session.getAttribute("userId");
    String branchCode = (String) session.getAttribute("branchCode");
    String branchName = "";
    String userName   = userId;

    if (userId == null || branchCode == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // ── Handle AJAX password change ────────────────────────────────────────────
    if ("changePassword".equals(request.getParameter("action"))) {
        String newPassword = request.getParameter("newPassword");
        if (newPassword != null && !newPassword.trim().isEmpty()) {
            Connection conn = null;
            PreparedStatement pstmt = null;
            try {
                conn = DBConnection.getConnection();
                String sql =
                    "UPDATE ACL.USERREGISTER SET PASSWD = acl.toolkit.encrypt(?), " +
                    "CREATED_BY = USER_ID WHERE USER_ID = ? AND BRANCH_CODE = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, newPassword);
                pstmt.setString(2, userId);
                pstmt.setString(3, branchCode);
                int rowsUpdated = pstmt.executeUpdate();
                response.setContentType("application/json");
                if (rowsUpdated > 0)
                    out.print("{\"success\":true,\"message\":\"Password changed successfully!\"}");
                else
                    out.print("{\"success\":false,\"message\":\"Failed to update password.\"}");
            } catch (Exception e) {
                response.setContentType("application/json");
                out.print("{\"success\":false,\"message\":\"Error: " + e.getMessage() + "\"}");
            } finally {
                try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
                try { if (conn  != null) conn.close();  } catch (Exception ignored) {}
            }
            return;
        }
    }

    // ── Check if password change is needed ────────────────────────────────────
    boolean needsPasswordChange = false;
    {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            String sql =
                "SELECT USER_ID, CREATED_BY FROM ACL.USERREGISTER " +
                "WHERE USER_ID=? AND BRANCH_CODE=?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            pstmt.setString(2, branchCode);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                String createdBy = rs.getString("CREATED_BY");
                if (createdBy != null && !userId.equals(createdBy))
                    needsPasswordChange = true;
            }
        } catch (Exception e) {
            System.err.println("Password check error: " + e.getMessage());
        } finally {
            try { if (rs    != null) rs.close();    } catch (Exception ignored) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
            try { if (conn  != null) conn.close();  } catch (Exception ignored) {}
        }
    }

    // ── Fetch branch name ─────────────────────────────────────────────────────
    try (Connection c = DBConnection.getConnection();
         PreparedStatement ps = c.prepareStatement(
             "SELECT NAME FROM HEADOFFICE.BRANCH WHERE BRANCH_CODE=?")) {
        ps.setString(1, branchCode);
        ResultSet rsBranch = ps.executeQuery();
        if (rsBranch.next()) branchName = rsBranch.getString("NAME");
    } catch (Exception e) { branchName = "Unknown Branch"; }

    // ── Fetch user full name ──────────────────────────────────────────────────
    try (Connection c = DBConnection.getConnection();
         PreparedStatement ps = c.prepareStatement(
             "SELECT NAME FROM ACL.USERREGISTER WHERE USER_ID=?")) {
        ps.setString(1, userId);
        ResultSet rsUser = ps.executeQuery();
        if (rsUser.next() && rsUser.getString("NAME") != null)
            userName = rsUser.getString("NAME");
    } catch (Exception e) { /* userName defaults to userId */ }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HR Payroll Dashboard</title>
    <link rel="stylesheet" href="css/main.css">
</head>
<body>

<!-- ═══════════ SIDEBAR ═══════════ -->
<div class="sidebar">
    <div class="profile-section">
        <img src="images/user.png" alt="Profile" class="profile-pic">
        <div class="user-name"><%= userName.toUpperCase() %></div>
    </div>

    <ul class="menu">

        <!-- Dashboard -->
        <li class="active" data-page="Dashboard/dashboard.jsp">
            <a href="#" onclick="loadPage('Dashboard/dashboard.jsp','Dashboard',this);return false;">
                <img src="images/right-arrow.png" width="18" height="18" alt="">
                <span>Dashboard</span>
            </a>
        </li>

        <!-- Masters -->
        <li data-page="Masters/masters.jsp">
            <a href="#" onclick="loadPage('Masters/masters.jsp','Masters',this);return false;">
                <img src="images/right-arrow.png" width="18" height="18" alt="">
                <span>Masters</span>
            </a>
        </li>

        <!-- Entry -->
        <li data-page="Entry/entry.jsp">
            <a href="#" onclick="loadPage('Entry/entry.jsp','Entry',this);return false;">
                <img src="images/right-arrow.png" width="18" height="18" alt="">
                <span>Entry</span>
            </a>
        </li>

        <!-- View -->
        <li data-page="View/view.jsp">
            <a href="#" onclick="loadPage('View/view.jsp','View',this);return false;">
                <img src="images/right-arrow.png" width="18" height="18" alt="">
                <span>View</span>
            </a>
        </li>

    </ul>

    <div class="logout">
        <a href="#" onclick="showLogoutConfirmation(event)">𓉘➜ Log Out</a>
    </div>
</div>

<!-- ═══════════ MAIN CONTENT ═══════════ -->
<div class="main-content">
    <header>
        <div class="title-row">
            <div class="bank-section">
                <div class="bank-icon">🏦</div>
                <h1 class="bank-title" id="bankNameTitle">Loading...</h1>
            </div>
            <div class="branch-section">
                <div class="branch-name" id="branchName">Loading...</div>
            </div>
        </div>
        <div class="nav-row">
            <div id="workingDate">Loading...</div>
        </div>
    </header>

    <iframe id="contentFrame" frameborder="0"></iframe>
</div>

<!-- Logout Modal -->
<div id="logoutModal" class="logout-modal">
    <div class="logout-modal-content">
        <h2>⚠️ Confirm Logout</h2>
        <p>Are you sure you want to log out?</p>
        <div class="logout-modal-buttons">
            <button class="logout-btn logout-btn-cancel" onclick="closeLogoutModal()">Cancel</button>
            <button class="logout-btn logout-btn-confirm" onclick="confirmLogout()">Yes, Logout</button>
        </div>
    </div>
</div>

<!-- Password Change Modal -->
<div class="modal-overlay" id="modalOverlay">
    <div class="password-change-modal">
        <div class="modal-header-custom">
            <h3>Change Your Password!</h3>
            <p>For security reasons, please set a new password</p>
        </div>
        <div class="modal-body-custom">
            <div id="passwordForm">
                <div class="alert-custom alert-error-custom" id="errorAlert"></div>
                <form id="changePasswordForm">
                    <div class="form-group-custom">
                        <label for="newPassword">New Password</label>
                        <div class="password-input-wrapper">
                            <input type="password" id="newPassword" name="newPassword"
                                   placeholder="Enter your new password" required autocomplete="new-password">
                            <img src="images/eye.png" class="eye-icon-modal" id="eyeIconNew"
                                 alt="Show" onclick="togglePasswordVisibility('newPassword','eyeIconNew')"
                                 style="display:none;">
                        </div>
                    </div>
                    <div class="form-group-custom">
                        <label for="confirmPassword">Confirm New Password</label>
                        <div class="password-input-wrapper">
                            <input type="password" id="confirmPassword" name="confirmPassword"
                                   placeholder="Re-enter your new password" required autocomplete="new-password">
                            <img src="images/eye.png" class="eye-icon-modal" id="eyeIconConfirm"
                                 alt="Show" onclick="togglePasswordVisibility('confirmPassword','eyeIconConfirm')"
                                 style="display:none;">
                        </div>
                    </div>
                    <button type="submit" class="btn-change-password" id="submitBtn">Change Password</button>
                </form>
            </div>
            <div class="success-message-container" id="successMessage">
                <div class="success-checkmark"></div>
                <div class="success-title">Password changed successfully</div>
                <button class="btn-ok" onclick="closeSuccessModal()">OK</button>
            </div>
        </div>
    </div>
</div>

<script>
// ── Password change modal ──────────────────────────────────────────────────
<% if (needsPasswordChange) { %>
window.addEventListener('DOMContentLoaded', function() {
    setTimeout(function() {
        document.getElementById('modalOverlay').classList.add('active');
    }, 500);
});
<% } %>

function closeSuccessModal() {
    document.getElementById('modalOverlay').classList.remove('active');
}

document.addEventListener('DOMContentLoaded', function() {
    var np = document.getElementById('newPassword');
    var cp = document.getElementById('confirmPassword');
    if (np) np.addEventListener('input', function() {
        document.getElementById('eyeIconNew').style.display = this.value.length > 0 ? 'block' : 'none';
    });
    if (cp) cp.addEventListener('input', function() {
        document.getElementById('eyeIconConfirm').style.display = this.value.length > 0 ? 'block' : 'none';
    });
});

function togglePasswordVisibility(inputId, iconId) {
    var input = document.getElementById(inputId);
    var icon  = document.getElementById(iconId);
    if (input.type === "password") { input.type = "text";     icon.src = "images/eye-hide.png"; }
    else                           { input.type = "password"; icon.src = "images/eye.png"; }
}

document.getElementById('changePasswordForm').addEventListener('submit', function(e) {
    e.preventDefault();
    var np  = document.getElementById('newPassword').value;
    var cp  = document.getElementById('confirmPassword').value;
    var err = document.getElementById('errorAlert');
    var btn = document.getElementById('submitBtn');
    err.style.display = 'none';
    if (np !== cp) { err.textContent = '❌ Passwords do not match!'; err.style.display='block'; return; }
    if (!np.trim()) { err.textContent = '❌ Password cannot be empty!'; err.style.display='block'; return; }
    btn.disabled = true; btn.textContent = 'Changing Password...';
    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'main.jsp?action=changePassword', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.onload = function() {
        if (xhr.status === 200) {
            try {
                var resp = JSON.parse(xhr.responseText);
                if (resp.success) {
                    document.getElementById('passwordForm').style.display = 'none';
                    document.getElementById('successMessage').classList.add('active');
                } else {
                    err.textContent = '❌ ' + resp.message; err.style.display='block';
                    btn.disabled=false; btn.textContent='Change Password';
                }
            } catch(ex) {
                err.textContent='❌ An error occurred.'; err.style.display='block';
                btn.disabled=false; btn.textContent='Change Password';
            }
        }
    };
    xhr.onerror = function() {
        err.textContent='❌ Network error.'; err.style.display='block';
        btn.disabled=false; btn.textContent='Change Password';
    };
    xhr.send('newPassword=' + encodeURIComponent(np));
});

// ── Session monitoring ─────────────────────────────────────────────────────
function checkSession() {
    fetch('sessionCheck.jsp')
        .then(function(r) { return r.json(); })
        .then(function(d) {
            if (!d.sessionValid) { sessionStorage.clear(); window.top.location.href = 'login.jsp'; }
        })
        .catch(function(e) { console.error('Session check error:', e); });
}
setInterval(checkSession, 30000);
document.addEventListener('visibilitychange', function() { if (!document.hidden) checkSession(); });
['click','keydown','mousemove'].forEach(function(ev) {
    document.addEventListener(ev, function() {
        if (!window._lastCheck || Date.now() - window._lastCheck > 10000) {
            window._lastCheck = Date.now(); checkSession();
        }
    }, { passive: true });
});

// ── Working date & bank name ───────────────────────────────────────────────
function updateWorkingDateAndBankName() {
    fetch('getWorkingDate.jsp')
        .then(function(r) { return r.json(); })
        .then(function(d) {
            if (d.error) {
                document.getElementById('workingDate').innerText    = 'Error: ' + d.error;
                document.getElementById('bankNameTitle').innerText  = 'Error Loading Bank Name';
                document.getElementById('branchName').innerText     = 'Error';
            } else {
                document.getElementById('workingDate').innerText   = 'Working Date: ' + d.workingDate;
                document.getElementById('bankNameTitle').innerText = d.bankName ? d.bankName.toUpperCase() : '';
                document.getElementById('branchName').innerText    = d.branchName ? d.branchName.toUpperCase() : '';
                sessionStorage.setItem('workingDate', d.workingDate);
                sessionStorage.setItem('bankName',    d.bankName);
                sessionStorage.setItem('branchName',  d.branchName);
                sessionStorage.setItem('bankCode',    d.bankCode);
                sessionStorage.setItem('branchCode',  d.branchCode);
            }
        })
        .catch(function(e) {
            document.getElementById('workingDate').innerText   = 'Connection Error';
            document.getElementById('bankNameTitle').innerText = 'Connection Error';
            document.getElementById('branchName').innerText    = 'Error';
        });
}

// ── Page loading ───────────────────────────────────────────────────────────
function loadPage(page, title, anchorEl) {
    sessionStorage.setItem('currentPage',  page);
    sessionStorage.setItem('currentTitle', title);
    document.getElementById('contentFrame').src = page;
    document.querySelectorAll('.menu li').forEach(function(li) { li.classList.remove('active'); });
    if (anchorEl && anchorEl.closest) {
        anchorEl.closest('li').classList.add('active');
    }
}

function updateParentBreadcrumb(breadcrumbPath, page) {
    sessionStorage.setItem('currentPage',  page);
    sessionStorage.setItem('currentTitle', breadcrumbPath);
}

function updateActiveMenuFromSession() {
    var savedTitle = sessionStorage.getItem('currentTitle');
    if (savedTitle) {
        document.querySelectorAll('.menu li').forEach(function(li) {
            var link = li.querySelector('a');
            if (link && link.textContent.trim().includes(savedTitle))
                li.classList.add('active');
            else
                li.classList.remove('active');
        });
    }
}

window.onload = function() {
    checkSession();
    updateWorkingDateAndBankName();
    setInterval(updateWorkingDateAndBankName, 30000);

    var savedPage  = sessionStorage.getItem('currentPage');
    var savedTitle = sessionStorage.getItem('currentTitle');

    if (savedPage && savedTitle) {
        document.getElementById('contentFrame').src = savedPage;
        updateActiveMenuFromSession();
    } else {
        var def = 'Dashboard/dashboard.jsp';
        document.getElementById('contentFrame').src = def;
        sessionStorage.setItem('currentPage',  def);
        sessionStorage.setItem('currentTitle', 'Dashboard');
        var dash = document.querySelector('.menu li[data-page="Dashboard/dashboard.jsp"]');
        if (dash) dash.classList.add('active');
    }
};

// ── Logout ─────────────────────────────────────────────────────────────────
function showLogoutConfirmation(event) {
    event.preventDefault();
    document.getElementById('logoutModal').style.display = 'block';
}
function closeLogoutModal() {
    document.getElementById('logoutModal').style.display = 'none';
}
function confirmLogout() {
    sessionStorage.clear();
    window.location.href = 'logout.jsp';
}
window.onclick = function(event) {
    if (event.target === document.getElementById('logoutModal')) closeLogoutModal();
};
document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeLogoutModal(); });
</script>
</body>
</html>
