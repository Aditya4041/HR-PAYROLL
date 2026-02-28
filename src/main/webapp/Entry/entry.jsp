<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String userId     = (String) session.getAttribute("userId");
    String branchCode = (String) session.getAttribute("branchCode");

    if (userId == null || branchCode == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Entry</title>
    <link rel="stylesheet" href="../css/cardView.css">
    <style>
        .card:nth-child(1) { background: linear-gradient(135deg, #4a9eff 0%, #3d85d9 100%); }
        .card:nth-child(2) { background: linear-gradient(135deg, #43c084 0%, #2fa06a 100%); }
        .card:nth-child(3) { background: linear-gradient(135deg, #f5a623 0%, #d4881a 100%); }
        .card:nth-child(4) { background: linear-gradient(135deg, #9b59b6 0%, #7d3c98 100%); }

        .cards-wrapper {
            grid-template-columns: repeat(4, 1fr);
            max-width: 1200px;
            margin: 0 auto;
        }
        .card-icon { font-size: 36px; margin-bottom: 10px; position: relative; z-index: 1; line-height: 1; }
        .card h3   { min-height: unset; font-size: 16px; margin-bottom: 6px; }
        .card p    { font-size: 13px; font-weight: 400; opacity: 0.90; line-height: 1.4; }
    </style>
</head>
<body>

<div class="dashboard-container">
    <div class="cards-wrapper">

        <!-- 1. Attendance Entry -->
        <div class="card" onclick="openInParentFrame('Entry/attendanceEntry.jsp','Entry > Attendance Entry')">
            <div class="card-icon">📋</div>
            <h3>Attendance Entry</h3>
            <p>Record daily attendance for employees</p>
        </div>

        <!-- 2. Leave Application -->
        <div class="card" onclick="openInParentFrame('Entry/leaveApplication.jsp','Entry > Leave Application')">
            <div class="card-icon">📝</div>
            <h3>Leave Application</h3>
            <p>Submit and manage leave requests</p>
        </div>

        <!-- 3. Payroll Processing -->
        <div class="card" onclick="openInParentFrame('Entry/payrollProcessing.jsp','Entry > Payroll Processing')">
            <div class="card-icon">💳</div>
            <h3>Payroll Processing</h3>
            <p>Process monthly payroll for employees</p>
        </div>

        <!-- 4. Loan / Advance Entry -->
        <div class="card" onclick="openInParentFrame('Entry/loanEntry.jsp','Entry > Loan / Advance Entry')">
            <div class="card-icon">🏧</div>
            <h3>Loan / Advance</h3>
            <p>Record employee loans and advances</p>
        </div>

    </div>
</div>

<script>
    function openInParentFrame(page, breadcrumbPath) {
        if (window.parent && window.parent.document) {
            var iframe = window.parent.document.getElementById("contentFrame");
            if (iframe) {
                iframe.src = page;
                if (window.parent.updateParentBreadcrumb) {
                    window.parent.updateParentBreadcrumb(breadcrumbPath, page);
                }
            }
        }
    }
</script>

</body>
</html>
