<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page contentType="application/json; charset=UTF-8" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String branchCode = (String) session.getAttribute("branchCode");

    if (branchCode == null) {
        out.print("{\"error\": \"Session expired\"}");
        return;
    }

    Connection conn = null;
    CallableStatement cstmt = null;
    PreparedStatement psBank = null, psBranch = null;
    ResultSet rsBank = null, rsBranch = null;

    try {
        conn = DBConnection.getConnection();

        String bankCode = "0100";

        String bankName = "";
        String bankShortName = "";

        String bankQuery = "SELECT NAME, SHORTNAME FROM GLOBALCONFIG.BANK WHERE BANK_CODE = ?";
        psBank = conn.prepareStatement(bankQuery);
        psBank.setString(1, bankCode);
        rsBank = psBank.executeQuery();

        if (rsBank.next()) {
            bankName      = rsBank.getString("NAME");
            bankShortName = rsBank.getString("SHORTNAME");
            session.setAttribute("bankCode",      bankCode);
            session.setAttribute("bankName",      bankName);
            session.setAttribute("bankShortName", bankShortName);
        } else {
            bankName      = "Bank Not Found";
            bankShortName = "N/A";
        }
        rsBank.close();
        psBank.close();

        String branchName = "";
        String branchQuery = "SELECT NAME FROM HEADOFFICE.BRANCH WHERE BRANCH_CODE = ?";
        psBranch = conn.prepareStatement(branchQuery);
        psBranch.setString(1, branchCode);
        rsBranch = psBranch.executeQuery();
        if (rsBranch.next()) {
            branchName = rsBranch.getString("NAME");
            session.setAttribute("branchName", branchName);
        } else {
            branchName = "Branch Not Found";
        }
        rsBranch.close();
        psBranch.close();

        String functionCall = "{? = call SYSTEM.FN_GET_WORKINGDATE(?, ?)}";
        cstmt = conn.prepareCall(functionCall);
        cstmt.registerOutParameter(1, Types.DATE);
        cstmt.setString(2, bankCode);
        cstmt.setString(3, branchCode);
        cstmt.execute();

        Date workingDate = cstmt.getDate(1);
        session.setAttribute("workingDate", workingDate);

        SimpleDateFormat sdf = new SimpleDateFormat("EEEE, MMMM d, yyyy");
        String formattedDate = sdf.format(workingDate);

        out.print("{");
        out.print("\"bankName\": \""      + bankName.replace("\"","'")   + "\",");
        out.print("\"bankShortName\": \"" + bankShortName.replace("\"","'") + "\",");
        out.print("\"bankCode\": \""      + bankCode                     + "\",");
        out.print("\"branchName\": \""    + branchName.replace("\"","'") + "\",");
        out.print("\"branchCode\": \""    + branchCode                   + "\",");
        out.print("\"workingDate\": \""   + formattedDate                + "\"");
        out.print("}");

    } catch (Exception e) {
        e.printStackTrace();
        out.print("{\"error\": \"" + e.getMessage().replace("\"","'") + "\"}");
    } finally {
        try { if (rsBank   != null) rsBank.close();   } catch (Exception ignored) {}
        try { if (rsBranch != null) rsBranch.close(); } catch (Exception ignored) {}
        try { if (psBank   != null) psBank.close();   } catch (Exception ignored) {}
        try { if (psBranch != null) psBranch.close(); } catch (Exception ignored) {}
        try { if (cstmt    != null) cstmt.close();    } catch (Exception ignored) {}
        try { if (conn     != null) conn.close();     } catch (Exception ignored) {}
    }
%>
