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
    <title>Employee Master</title>

    <%-- ── Shared tab-navigation CSS (same file used by addCustomer.jsp) ── --%>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/tabs-navigation.css">

    <style>
        /* ── Body & base ──────────────────────────────────────────── */
        * { box-sizing: border-box; }

        body {
            background-color: #e8e4fc;
            font-family: Arial, sans-serif;
            margin: 20px;
            padding: 0;
        }

        /* ── Fieldset ─────────────────────────────────────────────── */
        fieldset {
            background: #e8e4fc;
            border: 2px solid #aaa;
            margin: 10px 0 32px 0;
            padding: 15px 20px;
            min-width: 320px;
            border-radius: 9px;
            /* Smooth scroll target (from tabs-navigation.css) */
            scroll-margin-top: 120px;
        }

        legend {
            font-weight: bold;
            letter-spacing: 1px;
            font-size: 1.18em;
            padding: 0 10px;
            color: #373279;
        }

        /* ── Labels ───────────────────────────────────────────────── */
        label {
            font-size: 13px;
            margin-bottom: 3px;
            font-weight: bold;
            color: #373279;
        }

        /* ── Inputs / selects ─────────────────────────────────────── */
        input[type="text"],
        input[type="date"],
        input[type="email"],
        input[type="number"],
        select,
        textarea {
            padding: 4px 6px;
            font-size: 13px;
            border: 2px solid #C8B7F6;
            border-radius: 3px;
            font-family: Arial, sans-serif;
        }

        input[type="text"]:focus,
        input[type="date"]:focus,
        input[type="email"]:focus,
        input[type="number"]:focus,
        select:focus,
        textarea:focus {
            outline: none;
            border-color: #8066E8;
            box-shadow: 0 0 0 2px rgba(128,102,232,0.15);
        }

        input[readonly], input.auto-filled {
            background-color: #f0edff;
            color: #373279;
            border-color: #9c8ed8;
        }

        input:disabled {
            background-color: #f0f0f0;
            cursor: not-allowed;
        }

        /* Hide number spinners */
        input[type=number]::-webkit-inner-spin-button,
        input[type=number]::-webkit-outer-spin-button {
            -webkit-appearance: none !important; appearance: none !important; margin: 0 !important;
        }
        input[type=number] { -moz-appearance: textfield !important; appearance: textfield !important; }

        /* ── personal-grid (3-col) ───────────────────────────────── */
        .personal-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 12px 25px;
            align-items: start;
            margin-bottom: 12px;
        }
        .personal-grid > div { display: flex; flex-direction: column; }
        .personal-grid label { min-width: 10px; font-size: 13px; margin-bottom: 3px; font-weight: bold; color: #373279; }
        .personal-grid input[type="text"],
        .personal-grid input[type="date"],
        .personal-grid input[type="email"],
        .personal-grid input[type="number"],
        .personal-grid select {
            width: 90%; font-size: 13px; padding: 4px 6px;
            border-radius: 3px; border: 2px solid #C8B7F6;
        }
        .personal-grid .full-width { grid-column: span 3; width: 95%; }
        @media (max-width: 900px) {
            .personal-grid { grid-template-columns: repeat(2, 1fr); }
            .personal-grid .full-width { grid-column: span 2; }
        }
        @media (max-width: 600px) {
            .personal-grid { grid-template-columns: 1fr; }
            .personal-grid .full-width { grid-column: span 1; }
        }

        /* ── radio-group ─────────────────────────────────────────── */
        .radio-group {
            display: flex; align-items: center; gap: 5px;
            font-size: 13px; margin-top: 4px; flex-wrap: wrap;
        }
        .radio-group label {
            display: flex; align-items: center; gap: 4px;
            font-weight: 600; color: #373279; cursor: pointer; white-space: nowrap;
        }
        input[type="radio"] { transform: scale(0.9); accent-color: #373279; cursor: pointer; }

        /* ── checkbox-group ──────────────────────────────────────── */
        .checkbox-group {
            display: flex; flex-wrap: wrap; gap: 15px 25px;
            margin: 10px 0; padding: 10px 0;
        }
        .checkbox-group label {
            display: flex; align-items: center; gap: 8px;
            color: #373279; font-size: 13px; cursor: pointer; font-weight: 600;
        }
        .checkbox-group span { user-select: none; }

        /* ── checkbox-wrapper ────────────────────────────────────── */
        .checkbox-wrapper { display: flex; align-items: center; gap: 8px; margin-top: 5px; }
        .checkbox-wrapper span { color: #373279; font-size: 13px; font-weight: 600; }
        input[type="checkbox"] { width: 15px !important; height: 15px !important; accent-color: #373279; cursor: pointer; }

        /* ── form-buttons (shown only on last tab via tabs JS) ────── */
        .form-buttons {
            display: none;               /* hidden by default; tabs JS shows it */
            justify-content: center;
            align-items: center;
            margin: 25px 0;
            gap: 20px;
        }
        .form-buttons.show { display: flex !important; }
        .form-buttons button {
            background-color: #373279; color: white; border: none;
            padding: 10px 25px; border-radius: 6px;
            font-size: 14px; font-weight: bold; cursor: pointer;
            transition: background-color 0.3s ease, transform 0.2s ease;
        }
        .form-buttons button:hover { background-color: #2b0d73; transform: scale(1.05); }
        .form-buttons button:active { transform: scale(0.97); }
        @media (max-width: 600px) {
            .form-buttons { flex-direction: column; gap: 10px; }
            .form-buttons button { width: 80%; padding: 10px; }
        }

        /* ── section-heading ─────────────────────────────────────── */
        .section-heading {
            color: #373279; font-size: 15px; font-weight: bold;
            margin: 15px 0 10px 0; padding-bottom: 5px; border-bottom: 1px solid #9c8ed8;
        }

        /* ── header-section ──────────────────────────────────────── */
        .header-section {
            background-color: #f5f3ff;
            border: 2px solid #9c8ed8;
            padding: 15px 20px;
            margin-bottom: 0;           /* tab-nav sits immediately below */
            border-radius: 9px;
            display: flex; gap: 30px; align-items: center; flex-wrap: wrap;
        }
        .header-item { display: flex; align-items: center; gap: 10px; }
        .header-item > label { font-weight: bold; color: #373279; font-size: 13px; margin: 0; }
        .header-section input[type="number"],
        .header-section input[type="text"],
        .header-section select {
            padding: 6px 8px; border: 1px solid #888;
            border-radius: 3px; font-size: 13px; background-color: #fff;
        }
        .header-section input:focus, .header-section select:focus {
            outline: none; border-color: #8066E8;
            box-shadow: 0 0 0 2px rgba(128,102,232,0.15);
        }
        .emp-id-prefix {
            background: #373279; color: #fff; border: none;
            padding: 6px 10px; border-radius: 3px 0 0 3px;
            font-size: 13px; font-weight: 600; cursor: pointer; transition: background 0.2s; line-height: 1.4;
        }
        .emp-id-prefix:hover { background: #2b0d73; }
        .emp-id-num { border-radius: 0 3px 3px 0 !important; border-left: none !important; width: 80px !important; }
        .emp-title-select { border-radius: 3px 0 0 3px !important; }
        .emp-name-input { border-radius: 0 3px 3px 0 !important; min-width: 200px; }
        @media (max-width: 768px) {
            .header-section { flex-direction: column; align-items: flex-start; gap: 15px; }
            .emp-name-input { width: 100% !important; }
        }

        /* ── Inline field validation ─────────────────────────────── */
        .field-error-msg {
            color: #e53935; font-size: 11px; font-style: italic;
            display: block; margin-top: 2px;
        }
        input.field-invalid, select.field-invalid {
            border-color: #e53935 !important;
            box-shadow: 0 0 0 2px rgba(229,57,53,0.15);
        }

        /* ── Popup overlay ────────────────────────────────────────── */
        #empPopupOverlay {
            display: none; position: fixed; z-index: 99999; inset: 0;
            background: rgba(0,0,0,0.45); justify-content: center; align-items: center;
        }
        #empPopupOverlay.show { display: flex; }
        #empPopupBox {
            background: #fff; border-radius: 16px; padding: 40px 50px; text-align: center;
            box-shadow: 0 8px 40px rgba(0,0,0,0.25); min-width: 320px;
            animation: popupIn 0.35s cubic-bezier(0.34,1.56,0.64,1);
        }
        @keyframes popupIn {
            from { transform: scale(0.7); opacity: 0; }
            to   { transform: scale(1);   opacity: 1; }
        }
        #empPopupIcon  { font-size: 52px; margin-bottom: 12px; line-height: 1; }
        #empPopupTitle { font-size: 18px; font-weight: bold; color: #222; margin-bottom: 10px; }
        #empPopupSub   { font-size: 16px; font-weight: bold; color: #444; margin-bottom: 28px; }
        #empPopupOkBtn {
            background: #4caf50; color: #fff; border: none;
            padding: 12px 50px; border-radius: 8px;
            font-size: 16px; font-weight: bold; cursor: pointer; transition: background 0.2s;
        }
        #empPopupOkBtn:hover { background: #388e3c; }
        #empPopupOkBtn.error-btn { background: #e53935; }
        #empPopupOkBtn.error-btn:hover { background: #b71c1c; }

        /* ── Tab nav tweaks for 2 wide tabs ──────────────────────── */
        .tab-button { font-size: 15px; padding: 12px 20px; }
        .tab-number { width: 28px; height: 28px; font-size: 13px; }
    </style>
</head>
<body>

<%-- ══ Header — always visible above tabs ═══════════════════════════ --%>
<div class="header-section">
    <div class="header-item">
        <label>Employee Id:</label>
        <div style="display:flex;align-items:center;">
            <button type="button" class="emp-id-prefix" id="autoIdBtn" title="Auto-generate">—</button>
            <input type="number" class="emp-id-num" id="employeeId" name="employeeId"
                   placeholder="0" min="0">
        </div>
    </div>
    <div class="header-item">
        <label>Employee Name:</label>
        <div style="display:flex;align-items:center;">
            <select class="emp-title-select" id="nameTitle" name="nameTitle">
                <option value="Mr">Mr.</option>
                <option value="Mrs">Mrs.</option>
                <option value="Ms">Ms.</option>
                <option value="Dr">Dr.</option>
            </select>
            <input type="text" class="emp-name-input" id="employeeName"
                   name="employeeName" placeholder="Full Name">
        </div>
    </div>
</div>

<%-- ══ Main Form — tab JS will inject nav + wrap fieldsets ══════════ --%>
<form id="empForm" onsubmit="saveEmployee(event)">

    <%-- ════════════════════════════════════════════════════════════
         TAB 1 — PERSONAL DETAILS
    ════════════════════════════════════════════════════════════ --%>
    <fieldset>
        <legend>Personal Details</legend>

        <%-- Birth Date | Gender | Marital Status --%>
        <div class="personal-grid">
            <div>
                <label>Birth Date</label>
                <input type="date" id="birthDate" name="birthDate">
            </div>
            <div>
                <label>Gender</label>
                <select id="gender" name="gender" style="width:90%;">
                    <option value="">-- Select --</option>
                    <option value="M">Male</option>
                    <option value="F">Female</option>
                    <option value="O">Other</option>
                </select>
            </div>
            <div>
                <label>Marital Status</label>
                <div class="radio-group">
                    <label><input type="radio" name="maritalStatus" value="M"> Married</label>
                    <label><input type="radio" name="maritalStatus" value="U" checked> Unmarried</label>
                </div>
            </div>
        </div>

        <%-- Father/Husband | Spouse | Rel. with Spouse --%>
        <div class="personal-grid">
            <div>
                <label>Father / Husband</label>
                <input type="text" id="fatherHusband" name="fatherHusband">
            </div>
            <div>
                <label>Spouse</label>
                <input type="text" id="spouse" name="spouse">
            </div>
            <div>
                <label>Rel. with Spouse</label>
                <input type="text" id="relWithSpouse" name="relWithSpouse">
            </div>
        </div>

        <%-- Address 1 | Address 2 | Address 3 --%>
        <div class="personal-grid">
            <div>
                <label>Address 1</label>
                <textarea id="address1" name="address1" rows="2"
                          style="resize:vertical;width:90%;border:2px solid #C8B7F6;"></textarea>
            </div>
            <div>
                <label>Address 2</label>
                <textarea id="address2" name="address2" rows="2"
                          style="resize:vertical;width:90%;border:2px solid #C8B7F6;"></textarea>
            </div>
            <div>
                <label>Address 3</label>
                <textarea id="address3" name="address3" rows="2"
                          style="resize:vertical;width:90%;border:2px solid #C8B7F6;"></textarea>
            </div>
        </div>

        <%-- City | Taluka | Dist. | PIN | Phone | Email --%>
        <div class="personal-grid">
            <div>
                <label>City</label>
                <select id="city" name="city" style="width:90%;">
                    <option value="">-- Select City --</option>
                    <%
                        Connection connCity = null;
                        try {
                            connCity = DBConnection.getConnection();
                            PreparedStatement psCity = connCity.prepareStatement(
                                "SELECT CITY_CODE, NAME FROM GLOBALCONFIG.CITY ORDER BY NAME");
                            ResultSet rsCity = psCity.executeQuery();
                            while (rsCity.next()) { %>
                                <option value="<%= rsCity.getString("CITY_CODE") %>">
                                    <%= rsCity.getString("NAME") %></option>
                        <% } rsCity.close(); psCity.close();
                        } catch (Exception eC) { /* skip */ }
                        finally { if (connCity!=null) try{connCity.close();}catch(Exception ig){} }
                    %>
                </select>
            </div>
            <div>
                <label>Taluka</label>
                <select id="taluka" name="taluka" style="width:90%;">
                    <option value="">-- Select --</option>
                </select>
            </div>
            <div>
                <label>Dist.</label>
                <select id="district" name="district" style="width:90%;">
                    <option value="">-- Select --</option>
                </select>
            </div>
            <div>
                <label>PIN Code</label>
                <input type="text" id="pinCode" name="pinCode" maxlength="6"
                       oninput="this.value=this.value.replace(/\D/g,'')">
            </div>
            <div>
                <label>Phone No.</label>
                <input type="text" id="phoneNo" name="phoneNo" maxlength="10"
                       oninput="this.value=this.value.replace(/\D/g,'')">
            </div>
            <div>
                <label>Email ID</label>
                <input type="email" id="emailId" name="emailId">
            </div>
        </div>

        <%-- Education | Additional Skills | Graduate --%>
        <div class="personal-grid">
            <div>
                <label>Education</label>
                <input type="text" id="education" name="education">
            </div>
            <div>
                <label>Additional Skills</label>
                <input type="text" id="additionalSkills" name="additionalSkills">
            </div>
            <div>
                <label>&nbsp;</label>
                <div class="checkbox-wrapper">
                    <input type="checkbox" id="isGraduate" name="isGraduate" value="Y">
                    <span>Graduate</span>
                </div>
            </div>
        </div>
    </fieldset>

    <%-- ════════════════════════════════════════════════════════════
         TAB 2 — OFFICIAL DETAILS
    ════════════════════════════════════════════════════════════ --%>
    <fieldset>
        <legend>Official Details</legend>

        <%-- Appointment No | Appointment Date | Retirement/Left Date --%>
        <div class="personal-grid">
            <div>
                <label>Appointment No</label>
                <input type="text" id="appointmentNo" name="appointmentNo">
            </div>
            <div>
                <label>Appointment Date</label>
                <input type="date" id="appointmentDate" name="appointmentDate">
            </div>
            <div>
                <label>Retirement / Left Date</label>
                <input type="date" id="retirementDate" name="retirementDate" style="width:90%;">
            </div>
        </div>

        <%-- Joining Date | Employee Type | Sequence No --%>
        <div class="personal-grid">
            <div>
                <label>Joining Date <span style="color:#e53935;">*</span></label>
                <input type="date" id="joiningDate" name="joiningDate" required>
            </div>
            <div>
                <label>Employee Type</label>
                <div class="radio-group">
                    <label><input type="radio" name="employeeType" value="P"> Probation</label>
                    <label><input type="radio" name="employeeType" value="R" checked> Permanent</label>
                </div>
            </div>
            <div>
                <label>Sequence No</label>
                <input type="text" id="sequenceNo" name="sequenceNo">
            </div>
        </div>

        <%-- Document checkboxes --%>
        <h4 class="section-heading">Document Received</h4>
        <div class="checkbox-group">
            <label><input type="checkbox" name="docs" value="marksheet">  <span>Marksheet</span></label>
            <label><input type="checkbox" name="docs" value="birthProof"> <span>Birth Proof</span></label>
            <label><input type="checkbox" name="docs" value="joinReport"> <span>Join Report</span></label>
            <label><input type="checkbox" name="docs" value="oath">       <span>Oath of Secrecy</span></label>
            <label><input type="checkbox" name="docs" value="residence">  <span>Residence Proof</span></label>
            <label><input type="checkbox" name="docs" value="addQual">    <span>Add. Qualification Proof</span></label>
            <label><input type="checkbox" name="docs" value="doc7">       <span>Doc 7</span></label>
            <label><input type="checkbox" name="docs" value="doc8">       <span>Doc 8</span></label>
        </div>

        <%-- LFC From | LFC To | Emp Branch --%>
        <div class="personal-grid">
            <div>
                <label>LFC From</label>
                <input type="date" id="lfcFrom" name="lfcFrom">
            </div>
            <div>
                <label>LFC To</label>
                <input type="date" id="lfcTo" name="lfcTo">
            </div>
            <div>
                <label>Emp Branch</label>
                <select id="empBranch" name="empBranch" style="width:90%;">
                    <option value="">-- Select Branch --</option>
                    <%
                        Connection connBr = null;
                        try {
                            connBr = DBConnection.getConnection();
                            PreparedStatement psBr = connBr.prepareStatement(
                                "SELECT BRANCH_CODE, NAME FROM HEADOFFICE.BRANCH ORDER BY BRANCH_CODE");
                            ResultSet rsBr = psBr.executeQuery();
                            while (rsBr.next()) {
                                String bc = rsBr.getString("BRANCH_CODE");
                                String bn = rsBr.getString("NAME"); %>
                                <option value="<%= bc %>">HO CBS <%= bc %> - <%= bn %></option>
                        <% } rsBr.close(); psBr.close();
                        } catch (Exception eB) { out.println("<option value='0000'>HO CBS 000 - 0000</option>"); }
                        finally { if (connBr!=null) try{connBr.close();}catch(Exception ig){} }
                    %>
                </select>
            </div>
        </div>

        <%-- Category | Designation | Salary Branch --%>
        <div class="personal-grid">
            <div>
                <label>Category</label>
                <select id="category" name="category" style="width:90%;">
                    <option value="">-- Select --</option>
                    <option value="GEN">General</option>
                    <option value="OBC">OBC</option>
                    <option value="SC">SC</option>
                    <option value="ST">ST</option>
                    <option value="EWS">EWS</option>
                </select>
            </div>
            <div>
                <label>Designation</label>
                <select id="designation" name="designation" style="width:90%;">
                    <option value="">-- Select Designation --</option>
                    <%
                        Connection connDes = null;
                        try {
                            connDes = DBConnection.getConnection();
                            PreparedStatement psDes = connDes.prepareStatement(
                                "SELECT DESIG_CODE, DESIG_NAME FROM PAYROLL.DESIGNATION_MASTER ORDER BY DESIG_NAME");
                            ResultSet rsDes = psDes.executeQuery();
                            while (rsDes.next()) { %>
                                <option value="<%= rsDes.getString("DESIG_CODE") %>">
                                    <%= rsDes.getString("DESIG_NAME") %></option>
                        <% } rsDes.close(); psDes.close();
                        } catch (Exception eD) { /* skip */ }
                        finally { if (connDes!=null) try{connDes.close();}catch(Exception ig){} }
                    %>
                </select>
            </div>
            <div>
                <label>Salary Branch</label>
                <select id="salaryBranch" name="salaryBranch" style="width:90%;">
                    <option value="">-- Select Branch --</option>
                    <%
                        Connection connSBr = null;
                        try {
                            connSBr = DBConnection.getConnection();
                            PreparedStatement psSBr = connSBr.prepareStatement(
                                "SELECT BRANCH_CODE, NAME FROM HEADOFFICE.BRANCH ORDER BY BRANCH_CODE");
                            ResultSet rsSBr = psSBr.executeQuery();
                            while (rsSBr.next()) {
                                String bc = rsSBr.getString("BRANCH_CODE");
                                String bn = rsSBr.getString("NAME"); %>
                                <option value="<%= bc %>">HO CBS <%= bc %> - <%= bn %></option>
                        <% } rsSBr.close(); psSBr.close();
                        } catch (Exception eS) { out.println("<option value='0000'>HO CBS 000 - 0000</option>"); }
                        finally { if (connSBr!=null) try{connSBr.close();}catch(Exception ig){} }
                    %>
                </select>
            </div>
        </div>

        <%-- Salary Calculation | Is LWP --%>
        <div class="personal-grid">
            <div>
                <label>&nbsp;</label>
                <div class="checkbox-wrapper">
                    <input type="checkbox" id="salaryCalculation" name="salaryCalculation" value="Y">
                    <span>Salary Calculation</span>
                </div>
            </div>
            <div>
                <label>Is LWP</label>
                <div class="radio-group">
                    <label><input type="radio" name="isLWP" value="Y"> Yes</label>
                    <label><input type="radio" name="isLWP" value="N" checked> No</label>
                </div>
            </div>
            <div></div>
        </div>

        <%-- Current Basic Sal. | LIC ID Master | Special Allowance --%>
        <div class="personal-grid">
            <div>
                <label>Current Basic Sal.</label>
                <input type="text" id="currentBasicSal" name="currentBasicSal"
                       placeholder="0.00" oninput="this.value=this.value.replace(/[^0-9.]/g,'')">
            </div>
            <div>
                <label>LIC ID Master</label>
                <input type="text" id="licIdMaster" name="licIdMaster">
            </div>
            <div>
                <label>Special Allowance</label>
                <input type="text" id="specialAllowance" name="specialAllowance"
                       placeholder="0.00" oninput="this.value=this.value.replace(/[^0-9.]/g,'')">
            </div>
        </div>

        <%-- Confirmation No | Confirm Date | Salary A/c No --%>
        <div class="personal-grid">
            <div>
                <label>Confirmation No</label>
                <input type="text" id="confirmationNo" name="confirmationNo">
            </div>
            <div>
                <label>Confirm Date</label>
                <input type="date" id="confirmDate" name="confirmDate">
            </div>
            <div>
                <label>Salary A/c No.</label>
                <input type="text" id="salaryAcNo" name="salaryAcNo">
            </div>
        </div>
    </fieldset>

    <%-- ══ Save / Clear — shown only on last tab by tabs JS ════════ --%>
    <div class="form-buttons">
        <button type="submit">SAVE</button>
        <button type="reset" onclick="clearForm()">CLEAR</button>
    </div>

</form>

<%-- ══ Popup ════════════════════════════════════════════════════════ --%>
<div id="empPopupOverlay">
    <div id="empPopupBox">
        <div id="empPopupIcon"></div>
        <div id="empPopupTitle"></div>
        <div id="empPopupSub"></div>
        <button id="empPopupOkBtn" onclick="closePopup()">OK</button>
    </div>
</div>

<%-- ══ Tab Navigation JS ═════════════════════════════════════════════ --%>
<script src="<%= request.getContextPath() %>/js/emp-tabs-navigation.js"></script>

<script>
// ── Popup ─────────────────────────────────────────────────────────────────
function showPopup(type, title, sub) {
    document.getElementById('empPopupIcon').textContent  = type === 'success' ? '✔' : '✖';
    document.getElementById('empPopupIcon').style.color  = type === 'success' ? '#4caf50' : '#e53935';
    document.getElementById('empPopupTitle').textContent = title;
    document.getElementById('empPopupSub').textContent   = sub || '';
    var btn = document.getElementById('empPopupOkBtn');
    btn.className = type === 'error' ? 'error-btn' : '';
    document.getElementById('empPopupOverlay').classList.add('show');
}
function closePopup() {
    document.getElementById('empPopupOverlay').classList.remove('show');
}

// ── Helpers ───────────────────────────────────────────────────────────────
function clearForm() {
    document.getElementById('empForm').reset();
    document.getElementById('employeeId').value   = '';
    document.getElementById('employeeName').value = '';
    document.querySelectorAll('.field-error-msg').forEach(function(e){ e.remove(); });
    document.querySelectorAll('.field-invalid').forEach(function(e){ e.classList.remove('field-invalid'); });
    document.querySelectorAll('.error-message').forEach(function(e){ e.remove(); });
    document.querySelectorAll('.field-error').forEach(function(e){ e.classList.remove('field-error'); });
}

// ── Save ──────────────────────────────────────────────────────────────────
function saveEmployee(e) {
    e.preventDefault();

    // Clear stale inline errors
    document.querySelectorAll('.field-error-msg').forEach(function(el){ el.remove(); });
    document.querySelectorAll('.field-invalid').forEach(function(el){ el.classList.remove('field-invalid'); });

    var hasErrors = false;
    function showFieldError(id, msg) {
        var el = document.getElementById(id);
        if (!el) return;
        el.classList.add('field-invalid');
        var span = document.createElement('span');
        span.className   = 'field-error-msg';
        span.textContent = '⚠ ' + msg;
        el.parentNode.insertBefore(span, el.nextSibling);
        hasErrors = true;
    }

    if (!document.getElementById('employeeName').value.trim())
        showFieldError('employeeName', 'Employee Name is required');
    if (!document.getElementById('joiningDate').value)
        showFieldError('joiningDate', 'Joining Date is required');

    if (hasErrors) {
        document.querySelector('.field-invalid').scrollIntoView({ behavior: 'smooth', block: 'center' });
        return;
    }

    var fd = new FormData(document.getElementById('empForm'));
    fd.append('empId',   document.getElementById('employeeId').value);
    fd.append('empName', document.getElementById('employeeName').value.trim());
    fd.append('title',   document.getElementById('nameTitle').value);
    fd.append('action',  'save');

    fetch('EmployeeMasterServlet', { method: 'POST', body: fd })
        .then(function(r){ return r.json(); })
        .then(function(d){
            d.success
                ? showPopup('success', 'Saved Successfully', 'Employee record saved. ID: ' + (d.empId || ''))
                : showPopup('error', 'Save Failed', d.message);
        })
        .catch(function(){ showPopup('error', 'Network Error', 'Could not reach server.'); });
}

// ── Auto-generate ID button ───────────────────────────────────────────────
document.getElementById('autoIdBtn').addEventListener('click', function () {
    var empIdField = document.getElementById('employeeId');
    if (!parseInt(empIdField.value)) {
        empIdField.placeholder = 'AUTO';
    }
});

// ── Close popup on backdrop / Escape ─────────────────────────────────────
document.getElementById('empPopupOverlay').addEventListener('click', function (e) {
    if (e.target === this) closePopup();
});
document.addEventListener('keydown', function (e) { if (e.key === 'Escape') closePopup(); });
</script>

</body>
</html>
