<%@ page import="java.sql.*, db.DBConnection" %> 
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String userId     = request.getParameter("username");
    String password   = request.getParameter("password");
    String branchCode = request.getParameter("branch");

    String errorMessage        = null;
    boolean showForm           = true;

    String licensePopupType    = null;
    String licensePopupMessage = null;

    if (userId != null && password != null && branchCode != null) {

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();

            int dateDiff = 1;
            /* ---- No universal-parameter licence check for HR; always allow ---- */

            // Validate credentials
            String sql =
                "SELECT USER_ID FROM ACL.USERREGISTER " +
                "WHERE USER_ID=? AND acl.toolkit.decrypt(PASSWD)=? AND BRANCH_CODE=?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            pstmt.setString(2, password);
            pstmt.setString(3, branchCode);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                session.setAttribute("userId",     userId);
                session.setAttribute("branchCode", branchCode);

                PreparedStatement historyStmt = null;
                try {
                    String historySql =
                        "INSERT INTO ACL.USERREGISTERLOGINHISTORY " +
                        "(USER_ID, BRANCH_CODE, LOGIN_TIME) VALUES (?, ?, SYSDATE)";
                    historyStmt = conn.prepareStatement(historySql);
                    historyStmt.setString(1, userId);
                    historyStmt.setString(2, branchCode);
                    historyStmt.executeUpdate();
                } catch (Exception historyEx) {
                    System.err.println("Login history error: " + historyEx.getMessage());
                } finally {
                    try { if (historyStmt != null) historyStmt.close(); } catch (Exception ignored) {}
                }

                response.sendRedirect("main.jsp");
                showForm = false;

            } else {
                errorMessage = "Invalid username or password";
            }

        } catch (Exception e) {
            errorMessage = "Database Error: " + e.getMessage();
        } finally {
            try { if (rs    != null) rs.close();    } catch (Exception ignored) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
            try { if (conn  != null) conn.close();  } catch (Exception ignored) {}
        }
    }
%>

<% if (showForm) { %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>HR Payroll - Secure Login</title>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">
<link rel="stylesheet" href="css/login.css">
</head>
<body>

<div class="login-container">

    <div class="bank-brand">
        <img src="images/idsspl_logo.gif" alt="Logo" class="bank-logo">
        <div class="brand-title">HR PAYROLL SYSTEM</div>
        <div class="brand-sub">Human Resource & Payroll Management - Secure Access</div>
    </div>

    <form action="login.jsp" method="post" autocomplete="off">

        <div style="flex:1.4; display:flex; justify-content:center; align-items:center;">
            <img src="images/image.gif" alt="HR Payroll System Illustration">
        </div>

        <div style="flex:1; min-width:280px; text-align:left;">

            <select id="branch" name="branch" class="form-control" required>
                <option value="">-- Select Branch --</option>
                <%
                    try (Connection conn = DBConnection.getConnection();
                         java.sql.Statement stmt = conn.createStatement();
                         ResultSet branchRS = stmt.executeQuery(
                             "SELECT BRANCH_CODE, NAME FROM HEADOFFICE.BRANCH ORDER BY BRANCH_CODE")) {
                        while (branchRS.next()) {
                            String bCode = branchRS.getString("BRANCH_CODE");
                            String bName = branchRS.getString("NAME");
                            boolean selected = bCode.equals(request.getParameter("branch"));
                %>
                            <option value="<%=bCode%>" <%=selected?"selected":""%>>
                                <%=bCode%> - <%=bName%>
                            </option>
                <%
                        }
                    } catch (Exception ex) {
                        out.println("<option>Error loading branches</option>");
                    }
                %>
            </select>

            <input type="text" placeholder="Enter User ID" id="username" name="username"
                   class="form-control" required
                   value="<%=userId != null ? userId : ""%>">

            <div class="password-container">
                <input type="password" placeholder="Enter Password" id="password" name="password"
                       class="form-control" required>
                <img src="images/eye.png" id="eyeIcon" class="eye-icon"
                     alt="Show" onclick="togglePassword()">
            </div>

            <button type="submit" class="btn-login">Login</button>

            <% if (errorMessage != null) { %>
                <div class="error-message"><%= errorMessage %></div>
            <% } %>

            <div class="help-row">
                <a href="#">Forgot Password?</a>
            </div>
        </div>
    </form>

    <div class="login-footer">
        &copy; 2025 HR Payroll System. All rights reserved.
    </div>
</div>

<script>
const passwordInput = document.getElementById("password");
const eyeIcon       = document.getElementById("eyeIcon");
eyeIcon.style.display = "none";

function togglePassword() {
    if (passwordInput.type === "password") {
        passwordInput.type = "text";
        eyeIcon.src = "images/eye-hide.png";
    } else {
        passwordInput.type = "password";
        eyeIcon.src = "images/eye.png";
    }
}
passwordInput.addEventListener("input", function () {
    eyeIcon.style.display = passwordInput.value.length > 0 ? "block" : "none";
});
</script>

</body>
</html>
<% } %>
