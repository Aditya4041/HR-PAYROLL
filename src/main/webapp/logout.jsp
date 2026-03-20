<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page language="java" %>
<%
    // Get user details from session before invalidating
    String userId     = (String) session.getAttribute("userId");
    String branchCode = (String) session.getAttribute("branchCode");

    if (userId != null && branchCode != null) {
        Connection conn        = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBConnection.getConnection();

            // 1. Reset CURRENTLOGIN_STATUS to 'U' so user can log in again
            String updateStatusSql =
                "UPDATE ACL.USERREGISTER SET CURRENTLOGIN_STATUS = 'U' " +
                "WHERE USER_ID = ? AND BRANCH_CODE = ?";
            pstmt = conn.prepareStatement(updateStatusSql);
            pstmt.setString(1, userId);
            pstmt.setString(2, branchCode);
            pstmt.executeUpdate();
            pstmt.close();

            // 2. Stamp LOGOUT_TIME on the latest open login history record
            String updateLogoutSql =
                "UPDATE ACL.USERREGISTERLOGINHISTORY SET LOGOUT_TIME = SYSDATE " +
                "WHERE USER_ID = ? AND BRANCH_CODE = ? AND LOGOUT_TIME IS NULL " +
                "AND LOGIN_TIME = (SELECT MAX(LOGIN_TIME) FROM ACL.USERREGISTERLOGINHISTORY " +
                "                  WHERE USER_ID = ? AND BRANCH_CODE = ?)";
            pstmt = conn.prepareStatement(updateLogoutSql);
            pstmt.setString(1, userId);
            pstmt.setString(2, branchCode);
            pstmt.setString(3, userId);
            pstmt.setString(4, branchCode);
            pstmt.executeUpdate();

        } catch (Exception e) {
            System.err.println("Logout DB error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
            try { if (conn  != null) conn.close();  } catch (Exception ignored) {}
        }
    }

    // Destroy session and redirect
    session.invalidate();
    response.sendRedirect("login.jsp");
%>
