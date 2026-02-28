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
    <title>View</title>
    <link rel="stylesheet" href="../css/cardView.css">
    <style>
        .card:nth-child(1) { background: linear-gradient(135deg, #7c5cbf 0%, #5e3fa3 100%); }
        .card:nth-child(2) { background: linear-gradient(135deg, #43c084 0%, #2fa06a 100%); }
        .card:nth-child(3) { background: linear-gradient(135deg, #4a9eff 0%, #3d85d9 100%); }

        .cards-wrapper {
            grid-template-columns: repeat(3, 1fr);
            max-width: 900px;
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

        <!-- 1. Employee List -->
        <div class="card" onclick="openInParentFrame('View/employeeList.jsp','View > Employee List')">
            <div class="card-icon">👥</div>
            <h3>Employee List</h3>
            <p>View all employee records</p>
        </div>

        <!-- 2. Payslip View -->
        <div class="card" onclick="openInParentFrame('View/payslipView.jsp','View > Payslip View')">
            <div class="card-icon">🧾</div>
            <h3>Payslip View</h3>
            <p>View and print employee payslips</p>
        </div>

        <!-- 3. Attendance Report -->
        <div class="card" onclick="openInParentFrame('View/attendanceReport.jsp','View > Attendance Report')">
            <div class="card-icon">📊</div>
            <h3>Attendance Report</h3>
            <p>Monthly attendance summary</p>
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
