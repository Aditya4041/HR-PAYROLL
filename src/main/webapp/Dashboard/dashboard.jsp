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

    int recordsPerPage = 20;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard</title>
    <link rel="stylesheet" href="../css/totalCustomers.css">
    <style>
        .pagination-container { display:flex; justify-content:center; align-items:center; gap:10px; margin:20px 0; padding:15px; }
        .pagination-btn { background:#2b0d73; color:white; padding:8px 16px; border:none; border-radius:6px; cursor:pointer; font-size:14px; font-weight:bold; transition:background 0.3s; }
        .pagination-btn:disabled { background:#ccc; cursor:not-allowed; opacity:0.6; }
        .pagination-btn:hover:not(:disabled) { background:#1a0548; }
        .page-info { font-size:14px; color:#2b0d73; font-weight:bold; padding:0 15px; }
        .number-cell { text-align:center; font-weight:600; }
        .summary-cards { display:grid; grid-template-columns:repeat(4,1fr); gap:20px; margin:20px; }
        .summary-card { background:linear-gradient(135deg,#4a9eff,#3d85d9); color:white; padding:20px; border-radius:14px; text-align:center; box-shadow:0 6px 18px rgba(0,0,0,0.12); }
        .summary-card:nth-child(2) { background:linear-gradient(135deg,#43c084,#2fa06a); }
        .summary-card:nth-child(3) { background:linear-gradient(135deg,#f76c6c,#d94f4f); }
        .summary-card:nth-child(4) { background:linear-gradient(135deg,#f5a623,#d4881a); }
        .summary-card h3 { margin:0 0 8px; font-size:15px; opacity:0.9; }
        .summary-card p  { margin:0; font-size:30px; font-weight:700; }
    </style>
    <script>
        let allData = [];
        let currentPage = 1;
        const recordsPerPage = <%= recordsPerPage %>;

        function getFilteredData() {
            var q = document.getElementById("searchInput").value.toLowerCase().trim();
            return q === "" ? allData.slice() : allData.filter(function(r) {
                return r.branchCode.toLowerCase().indexOf(q) > -1 ||
                       r.branchName.toLowerCase().indexOf(q) > -1;
            });
        }

        function searchTable() { displayData(getFilteredData(), 1); }

        function displayData(data, page) {
            currentPage = page;
            var tbody = document.querySelector("#dataTable tbody");
            tbody.innerHTML = "";

            if (data.length === 0) {
                tbody.innerHTML = "<tr><td colspan='6' class='no-data'>No data found.</td></tr>";
                updatePagination(0, page); return;
            }

            var start = (page - 1) * recordsPerPage;
            var end   = Math.min(start + recordsPerPage, data.length);
            for (var i = start; i < end; i++) {
                var r  = data[i];
                var tr = tbody.insertRow();
                tr.innerHTML =
                    "<td class='number-cell'>" + (i+1)              + "</td>" +
                    "<td>"                      + r.branchCode       + "</td>" +
                    "<td>"                      + r.branchName       + "</td>" +
                    "<td class='number-cell'>"  + r.totalEmployee    + "</td>" +
                    "<td class='number-cell'>"  + r.activeEmployee   + "</td>" +
                    "<td class='number-cell'>"  + r.inactiveEmployee + "</td>";
            }
            updatePagination(data.length, page);
        }

        function updatePagination(total, page) {
            var totalPages = Math.max(1, Math.ceil(total / recordsPerPage));
            document.getElementById("prevBtn").disabled = (page <= 1);
            document.getElementById("nextBtn").disabled = (page >= totalPages);
            document.getElementById("pageInfo").textContent = "Page " + page + " of " + totalPages;
        }

        function previousPage() { if (currentPage > 1) displayData(getFilteredData(), currentPage - 1); }
        function nextPage() {
            var data = getFilteredData();
            var tp   = Math.ceil(data.length / recordsPerPage);
            if (currentPage < tp) displayData(data, currentPage + 1);
        }
    </script>
</head>
<body>
    <h2>HR Payroll Dashboard - Branch-wise Employee Summary</h2>

    <div class="summary-cards">
        <div class="summary-card">
            <h3>Total Employees</h3>
            <p id="totalEmpCard">—</p>
        </div>
        <div class="summary-card">
            <h3>Active Employees</h3>
            <p id="activeEmpCard">—</p>
        </div>
        <div class="summary-card">
            <h3>On Leave Today</h3>
            <p id="leaveCard">—</p>
        </div>
        <div class="summary-card">
            <h3>Pending Payroll</h3>
            <p id="payrollCard">—</p>
        </div>
    </div>

    <div class="search-container">
        <input type="text" id="searchInput" onkeyup="searchTable()"
               placeholder="🔍 Search by Branch Code or Branch Name">
    </div>

    <div class="table-container">
        <table id="dataTable">
            <thead>
                <tr>
                    <th>SR NO</th>
                    <th>BRANCH CODE</th>
                    <th>BRANCH NAME</th>
                    <th>TOTAL EMPLOYEE</th>
                    <th>ACTIVE EMPLOYEE</th>
                    <th>INACTIVE EMPLOYEE</th>
                </tr>
            </thead>
            <tbody>
                <%
                Connection conn = null;
                PreparedStatement ps = null;
                ResultSet rs = null;
                int totalEmpSum = 0, activeEmpSum = 0;

                try {
                    conn = DBConnection.getConnection();
                    // Fetch branch list; employee counts to be extended with HR tables
                    String query =
                        "SELECT B.BRANCH_CODE, B.NAME " +
                        "FROM HEADOFFICE.BRANCH B " +
                        "ORDER BY B.BRANCH_CODE";
                    ps = conn.prepareStatement(query);
                    rs = ps.executeQuery();

                    boolean hasData  = false;
                    int displayed    = 0;
                    int srNo         = 1;

                    while (rs.next()) {
                        hasData = true;
                        String bCode = rs.getString("BRANCH_CODE");
                        String bName = rs.getString("NAME");
                        int total    = 0;
                        int active   = 0;
                        int inactive = 0;

                        totalEmpSum  += total;
                        activeEmpSum += active;

                        out.println("<script>");
                        out.println("allData.push({");
                        out.println("  branchCode:'"       + (bCode != null ? bCode : "")                                + "',");
                        out.println("  branchName:'"       + (bName != null ? bName.replace("'","\\'") : "")             + "',");
                        out.println("  totalEmployee:"     + total    + ",");
                        out.println("  activeEmployee:"    + active   + ",");
                        out.println("  inactiveEmployee:"  + inactive);
                        out.println("});");
                        out.println("</script>");

                        if (displayed < recordsPerPage) {
                            out.println("<tr>");
                            out.println("<td class='number-cell'>" + srNo                                       + "</td>");
                            out.println("<td>"                      + (bCode != null ? bCode : "")              + "</td>");
                            out.println("<td>"                      + (bName != null ? bName : "")              + "</td>");
                            out.println("<td class='number-cell'>"  + total                                     + "</td>");
                            out.println("<td class='number-cell'>"  + active                                    + "</td>");
                            out.println("<td class='number-cell'>"  + inactive                                  + "</td>");
                            out.println("</tr>");
                            displayed++;
                        }
                        srNo++;
                    }

                    if (!hasData)
                        out.println("<tr><td colspan='6' class='no-data'>No branch data available.</td></tr>");

                } catch (Exception e) {
                    out.println("<tr><td colspan='6' class='no-data'>Error: " + e.getMessage() + "</td></tr>");
                    e.printStackTrace();
                } finally {
                    try { if (rs   != null) rs.close();   } catch (Exception ignored) {}
                    try { if (ps   != null) ps.close();   } catch (Exception ignored) {}
                    try { if (conn != null) conn.close(); } catch (Exception ignored) {}
                }
                %>
            </tbody>
        </table>
    </div>

    <div class="pagination-container">
        <button id="prevBtn" class="pagination-btn" onclick="previousPage()">← Previous</button>
        <span   id="pageInfo" class="page-info">Page 1</span>
        <button id="nextBtn"  class="pagination-btn" onclick="nextPage()">Next →</button>
    </div>

    <script>
        (function() {
            var totalPages = Math.ceil(allData.length / recordsPerPage) || 1;
            document.getElementById("prevBtn").disabled = true;
            document.getElementById("nextBtn").disabled = (totalPages <= 1);
            document.getElementById("pageInfo").textContent = "Page 1 of " + totalPages;

            // Update summary cards
            var total = allData.reduce(function(s,r){ return s + r.totalEmployee; }, 0);
            var active= allData.reduce(function(s,r){ return s + r.activeEmployee; }, 0);
            document.getElementById("totalEmpCard").textContent  = total;
            document.getElementById("activeEmpCard").textContent = active;
            document.getElementById("leaveCard").textContent     = "—";
            document.getElementById("payrollCard").textContent   = "—";
        })();
    </script>
</body>
</html>
