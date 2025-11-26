<%@ include file="header.jsp" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>



<!DOCTYPE html>
<html>
<head>
    <title>Currency Converter</title>

    <!-- Bootstrap 5 CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <style>
        :root{
            --card-max-width: 520px;
            --result-width: 320px;
            --page-padding: 2.25rem;
        }
        body {
            background: linear-gradient(to right, #74ebd5, #ACB6E5);
            font-family: 'Segoe UI', sans-serif;
            min-height: 100vh;
        }
        .main-flex {
            display: flex;
            gap: 2.5rem;
            justify-content: center;
            align-items: center;
            padding: var(--page-padding);
            min-height: calc(100vh - 40px);
            box-sizing: border-box;
        }
        .left-card { flex: 0 1 var(--card-max-width); width:100%; max-width:var(--card-max-width); }
        .right-panel { flex: 0 0 var(--result-width); width:var(--result-width); min-width:230px; }
        .card-convert { margin:0; padding:24px; border-radius:15px; box-shadow:0 8px 30px rgba(0,0,0,0.12); }
        .result-card { border-radius:15px; padding:1.25rem; box-shadow:0 8px 30px rgba(0,0,0,0.08); }
        .rotate-swap { transform: rotate(180deg); transition: 0.4s ease; }
        .btn-convert { background-color: #0d6efd; border-color: #0d6efd; }
        .btn-convert:hover { background-color: #0056b3 !important; }
        .result-alert { font-size: 14px; padding: 10px 14px; margin-bottom: 0; }
        .flag-img { width:28px; height:20px; object-fit:cover; border-radius:3px; display:inline-block; margin-right:8px; }
        @media (max-width: 991.98px) {
            .main-flex { flex-direction: column; align-items: stretch; padding:1.25rem; min-height:auto; }
            .right-panel { width:100%; flex:1 1 auto; margin-top:1rem; }
        }
    </style>
</head>

<body>

<div class="main-flex container-fluid">

    <!-- LEFT: Form -->
    <div class="left-card">
        <div class="card card-convert bg-white">
            <h3 class="text-center text-primary fw-bold mb-4">Currency Converter</h3>

            <form method="post" action="convert" id="convertForm">

                <!-- Amount -->
                <div class="mb-3">
                    <label class="form-label fw-semibold">Amount</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-cash-coin"></i></span>
                        <input type="number" step="0.01" name="amount" class="form-control"
                               placeholder="Enter amount"
                               value="${not empty amount ? amount : ''}"
                               required>
                    </div>
                </div>

                <!-- From Currency (with flag img) -->
                <div class="mb-3">
                    <label class="form-label fw-semibold">From Currency</label>
                    <div class="input-group align-items-center">
                        <span class="input-group-text"><i class="bi bi-currency-exchange"></i></span>

                        <!-- Flag for FROM -->
                        <img id="fromFlag" class="flag-img" src="" alt="" style="display:none" />

                        <select name="fromCurrency" id="fromCurrency" class="form-select" required>
                            <c:forEach var="entry" items="${currencies}">
                                <option value="${entry.key}"
                                        data-country="${isoMap[entry.key]}"
                                        <c:if test="${entry.key == selectedFrom}">selected</c:if>>
                                    ${entry.key} - ${entry.value}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <!-- Swap -->
                <div class="text-center mb-3">
                    <button type="button" id="swapBtn" class="btn btn-outline-secondary rounded-circle px-3 py-2"
                            style="font-size: 22px;">
                        <i class="bi bi-arrow-down-up"></i>
                    </button>
                </div>

                <!-- To Currency (with flag img) -->
                <div class="mb-4">
                    <label class="form-label fw-semibold">To Currency</label>
                    <div class="input-group align-items-center">
                        <span class="input-group-text"><i class="bi bi-cash-stack"></i></span>

                        <!-- Flag for TO -->
                        <img id="toFlag" class="flag-img" src="" alt="" style="display:none" />

                        <select name="toCurrency" id="toCurrency" class="form-select" required>
                            <c:forEach var="entry" items="${currencies}">
                                <option value="${entry.key}"
                                        data-country="${isoMap[entry.key]}"
                                        <c:if test="${entry.key == selectedTo}">selected</c:if>>
                                    ${entry.key} - ${entry.value}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <button type="submit" class="btn btn-primary w-100 btn-convert">
                    Convert <i class="bi bi-arrow-right-circle ms-1"></i>
                </button>

            </form>
        </div>
    </div>

  <!-- RIGHT: Result panel (with history) -->
<div class="right-panel">
    <div class="card result-card bg-white h-100 d-flex flex-column justify-content-center">
        <h5 class="text-center fw-bold text-secondary mb-3">Converted Result</h5>

        <c:if test="${not empty result}">
            <div class="alert alert-success text-center fw-semibold result-alert">
                ${result}
            </div>
        </c:if>

        <c:if test="${not empty error}">
            <div class="alert alert-danger text-center fw-semibold result-alert">
                ${error}
            </div>
        </c:if>

        <c:if test="${empty result and empty error}">
            <p class="text-muted text-center mb-0">No result yet. Enter details and convert.</p>
        </c:if>

        <!-- History: last 5 conversions from session -->
        <div class="mt-3">
            <h6 class="text-center text-muted mb-2">Last 5 conversions</h6>

            <c:choose>
                <c:when test="${not empty sessionScope.conversionHistory}">
                    <ul class="list-group">
                        <c:forEach var="entry" items="${sessionScope.conversionHistory}">
                            <li class="list-group-item py-2">
                                <small class="text-muted me-1"><i class="bi bi-clock-history"></i></small>
                                <span style="font-size:0.95rem">${fn:escapeXml(entry)}</span>
                            </li>
                        </c:forEach>
                    </ul>
                </c:when>
                <c:otherwise>
                    <p class="text-center text-muted small mb-0">No history yet.</p>
                </c:otherwise>
            </c:choose>
        </div>

    </div>
</div>

</div>

<script>
(function(){
    // Build a URL for FlagCDN (40px width PNG)
    function flagUrl(iso) {
        if(!iso) return "";
        return "https://flagcdn.com/w40/" + iso.toLowerCase() + ".png";
    }

    // elements
    const fromSel = document.getElementById("fromCurrency");
    const toSel   = document.getElementById("toCurrency");
    const fromImg = document.getElementById("fromFlag");
    const toImg   = document.getElementById("toFlag");
    const swapBtn = document.getElementById("swapBtn");

    function updateFlag(selectEl, imgEl) {
        if(!selectEl || !imgEl) return;
        const opt = selectEl.options[selectEl.selectedIndex];
        const iso = opt ? opt.getAttribute("data-country") : null;
        if(iso && iso !== "null" && iso !== "") {
            imgEl.src = flagUrl(iso);
            imgEl.alt = iso.toUpperCase();
            imgEl.style.display = 'inline-block';
        } else {
            imgEl.style.display = 'none';
            imgEl.src = '';
            imgEl.alt = '';
        }
    }

    // initial
    updateFlag(fromSel, fromImg);
    updateFlag(toSel, toImg);

    // on change
    if(fromSel) fromSel.addEventListener('change', () => updateFlag(fromSel, fromImg));
    if(toSel)   toSel.addEventListener('change', () => updateFlag(toSel, toImg));

    // swap button: swap values and update flags
    if(swapBtn && fromSel && toSel) {
        swapBtn.addEventListener('click', () => {
            swapBtn.classList.add('rotate-swap');
            setTimeout(() => swapBtn.classList.remove('rotate-swap'), 400);

            const t = fromSel.value;
            fromSel.value = toSel.value;
            toSel.value = t;

            // update flags after swapping values
            updateFlag(fromSel, fromImg);
            updateFlag(toSel, toImg);
        });
    }
})();
</script>

</body>
</html>
