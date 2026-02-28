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
    </style>
    <script>
        let allData = [];
        let currentPage = 1;
        const recordsPerPage = <%= recordsPerPage %>;

        function getFilteredData() {
            var q = document.getElementById("searchInput").value.toLowerCase().trim();
            return q === "" ? allData.slice() : allData.filter(function(r) {
                return r.branchCode.toLowerCase().indexOf(q) > -1 ||
                       r.empNo.toLowerCase().indexOf(q) > -1 ||
                       r.empName.toLowerCase().indexOf(q) > -1;
            });
        }

        function searchTable() { displayData(getFilteredData(), 1); }

        function displayData(data, page) {
            currentPage = page;
            var tbody = document.querySelector("#dataTable tbody");
            tbody.innerHTML = "";

            if (data.length === 0) {
                tbody.innerHTML = "<tr><td colspan='7' class='no-data'>No data found.</td></tr>";
                updatePagination(0, page); 
                return;
            }

            var start = (page - 1) * recordsPerPage;
            var end   = Math.min(start + recordsPerPage, data.length);
            for (var i = start; i < end; i++) {
                var r  = data[i];
                var tr = tbody.insertRow();
                tr.innerHTML =
                    "<td class='number-cell'>" + (i+1)              + "</td>" +
                    "<td>"                      + r.branchCode       + "</td>" +
                    "<td>"                      + r.empNo            + "</td>" +
                    "<td>"                      + r.empName          + "</td>" +
                    "<td>"                      + r.joinDate         + "</td>" +
                    "<td>"                      + r.leftDate         + "</td>" +
                    "<td>"                      + r.salBranchCode    + "</td>";
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
    <h2>HR Payroll Dashboard - Employee Summary</h2>

    <div class="search-container">
        <input type="text" id="searchInput" onkeyup="searchTable()"
               placeholder="🔍 Search by Branch Code, Employee ID or Name">
    </div>

    <div class="table-container">
        <table id="dataTable">
            <thead>
                <tr>
                    <th>SR NO</th>
                    <th>BRANCH CODE</th>
                    <th>EMPLOYEE ID</th>
                    <th>EMPLOYEE NAME</th>
                    <th>EMPLOYEE JOIN DATE</th>
                    <th>EMPLOYEE LEFT DATE</th>
                    <th>SALARY BRANCH CODE</th>
                </tr>
            </thead>
            <tbody>
                <%
                Connection conn = null;
                PreparedStatement ps = null;
                ResultSet rs = null;

                try {
                    conn = DBConnection.getConnection();
                    // Fetch employee list from PAYROLL.EMPLOYEE_MST
                    String query =
                        "SELECT BRANCH_CODE, EMP_NO, EMP_NAME, JOIN_DATE, LEFT_DATE, SAL_BRANCH_CODE " +
                        "FROM PAYROLL.EMPLOYEE_MST " +
                        "ORDER BY BRANCH_CODE, EMP_NO";
                    ps = conn.prepareStatement(query);
                    rs = ps.executeQuery();

                    boolean hasData  = false;
                    int displayed    = 0;
                    int srNo         = 1;

                    while (rs.next()) {
                        hasData = true;
                        String brCode       = rs.getString("BRANCH_CODE");
                        String empNo        = rs.getString("EMP_NO");
                        String empName      = rs.getString("EMP_NAME");
                        java.sql.Date joinDate   = rs.getDate("JOIN_DATE");
                        java.sql.Date leftDate   = rs.getDate("LEFT_DATE");
                        String salBranchCode    = rs.getString("SAL_BRANCH_CODE");

                        // Format dates
                        String joinDateStr = (joinDate != null) ? new java.text.SimpleDateFormat("dd-MM-yyyy").format(joinDate) : "";
                        String leftDateStr = (leftDate != null) ? new java.text.SimpleDateFormat("dd-MM-yyyy").format(leftDate) : "";

                        out.println("<script>");
                        out.println("allData.push({");
                        out.println("  branchCode:'"       + (brCode != null ? brCode : "")                                + "',");
                        out.println("  empNo:'"            + (empNo != null ? empNo.replace("'","\\'") : "")              + "',");
                        out.println("  empName:'"          + (empName != null ? empName.replace("'","\\'") : "")          + "',");
                        out.println("  joinDate:'"         + joinDateStr                                                   + "',");
                        out.println("  leftDate:'"         + leftDateStr                                                   + "',");
                        out.println("  salBranchCode:'"    + (salBranchCode != null ? salBranchCode : "")                 + "'");
                        out.println("});");
                        out.println("</script>");

                        if (displayed < recordsPerPage) {
                            out.println("<tr>");
                            out.println("<td class='number-cell'>" + srNo                                           + "</td>");
                            out.println("<td>"                      + (brCode != null ? brCode : "")               + "</td>");
                            out.println("<td>"                      + (empNo != null ? empNo : "")                 + "</td>");
                            out.println("<td>"                      + (empName != null ? empName : "")             + "</td>");
                            out.println("<td>"                      + joinDateStr                                  + "</td>");
                            out.println("<td>"                      + leftDateStr                                  + "</td>");
                            out.println("<td>"                      + (salBranchCode != null ? salBranchCode : "") + "</td>");
                            out.println("</tr>");
                            displayed++;
                        }
                        srNo++;
                    }

                    if (!hasData)
                        out.println("<tr><td colspan='7' class='no-data'>No employee data available.</td></tr>");

                } catch (Exception e) {
                    out.println("<tr><td colspan='7' class='no-data'>Error: " + e.getMessage() + "</td></tr>");
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
            
            // Display initial page
            displayData(allData, 1);
        })();
    </script>
</body>
</html>
