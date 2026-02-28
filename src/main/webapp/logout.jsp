<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page language="java" %>
<%
    String userId     = (String) session.getAttribute("userId");
    String branchCode = (String) session.getAttribute("branchCode");

    if (userId != null && branchCode != null) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBConnection.getConnection();

            String updateLogoutTimeSql =
                "UPDATE ACL.USERREGISTERLOGINHISTORY SET LOUGOUT_TIME = SYSDATE " +
                "WHERE USER_ID = ? AND BRANCH_CODE = ? AND LOUGOUT_TIME IS NULL " +
                "AND LOGIN_TIME = (SELECT MAX(LOGIN_TIME) FROM ACL.USERREGISTERLOGINHISTORY " +
                "WHERE USER_ID = ? AND BRANCH_CODE = ?)";
            pstmt = conn.prepareStatement(updateLogoutTimeSql);
            pstmt.setString(1, userId);
            pstmt.setString(2, branchCode);
            pstmt.setString(3, userId);
            pstmt.setString(4, branchCode);
            pstmt.executeUpdate();

        } catch (Exception e) {
            System.err.println("Error updating logout time: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
            try { if (conn  != null) conn.close();  } catch (Exception ignored) {}
        }
    }

    session.invalidate();
    response.sendRedirect("login.jsp");
%>
