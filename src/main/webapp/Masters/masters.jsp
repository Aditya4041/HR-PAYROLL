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
    <title>Masters</title>
    <link rel="stylesheet" href="../css/cardView.css">
    <style>
        .card:nth-child(1)  { background: linear-gradient(135deg, #4a9eff 0%, #3d85d9 100%); }
        .card:nth-child(2)  { background: linear-gradient(135deg, #43c084 0%, #2fa06a 100%); }
        .card:nth-child(3)  { background: linear-gradient(135deg, #f76c6c 0%, #d94f4f 100%); }
        .card:nth-child(4)  { background: linear-gradient(135deg, #f5a623 0%, #d4881a 100%); }
        .card:nth-child(5)  { background: linear-gradient(135deg, #9b59b6 0%, #7d3c98 100%); }
        .card:nth-child(6)  { background: linear-gradient(135deg, #1abc9c 0%, #148f77 100%); }
        .card:nth-child(7)  { background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%); }
        .card:nth-child(8)  { background: linear-gradient(135deg, #3498db 0%, #2980b9 100%); }

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

        <!-- 1. Employee Master -->
        <div class="card" onclick="openInParentFrame('Masters/employeeMaster.jsp','Masters > Employee Master')">
            <div class="card-icon">👤</div>
            <h3>Employee Master</h3>
            <p>Add &amp; manage employee records</p>
        </div>

        <!-- 2. Department Master -->
        <div class="card" onclick="openInParentFrame('Masters/departmentMaster.jsp','Masters > Department Master')">
            <div class="card-icon">🏬</div>
            <h3>Department Master</h3>
            <p>Manage departments and cost centres</p>
        </div>

        <!-- 3. Designation Master -->
        <div class="card" onclick="openInParentFrame('Masters/designationMaster.jsp','Masters > Designation Master')">
            <div class="card-icon">🏷️</div>
            <h3>Designation Master</h3>
            <p>Define designations and grades</p>
        </div>

        <!-- 4. Salary Component Master -->
        <div class="card" onclick="openInParentFrame('Masters/salaryComponentMaster.jsp','Masters > Salary Component Master')">
            <div class="card-icon">💰</div>
            <h3>Salary Component</h3>
            <p>Configure earning &amp; deduction heads</p>
        </div>

        <!-- 5. Leave Master -->
        <div class="card" onclick="openInParentFrame('Masters/leaveMaster.jsp','Masters > Leave Master')">
            <div class="card-icon">📅</div>
            <h3>Leave Master</h3>
            <p>Define leave types and entitlements</p>
        </div>

        <!-- 6. Holiday Master -->
        <div class="card" onclick="openInParentFrame('Masters/holidayMaster.jsp','Masters > Holiday Master')">
            <div class="card-icon">🗓️</div>
            <h3>Holiday Master</h3>
            <p>Set up yearly holiday calendar</p>
        </div>

        <!-- 7. Bank Master -->
        <div class="card" onclick="openInParentFrame('Masters/bankMaster.jsp','Masters > Bank Master')">
            <div class="card-icon">🏦</div>
            <h3>Bank Master</h3>
            <p>Manage employee bank account details</p>
        </div>

        <!-- 8. Grade Master -->
        <div class="card" onclick="openInParentFrame('Masters/gradeMaster.jsp','Masters > Grade Master')">
            <div class="card-icon">📊</div>
            <h3>Grade Master</h3>
            <p>Define pay grades and salary bands</p>
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
