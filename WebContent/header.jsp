<!-- header.jsp -->
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<style>
    .cc-navbar {
        background: linear-gradient(90deg, #0b73f6, #0a6ef2);
        box-shadow: 0 8px 24px rgba(0,0,0,0.18);
        padding: 14px 28px;
    }

    .cc-brand {
        font-size: 1.3rem;
        font-weight: 700;
        letter-spacing: 0.3px;
    }

    .cc-logo {
        width: 44px;
        height: 44px;
        background: rgba(255,255,255,0.15);
        border-radius: 10px;
        padding: 6px;
        box-shadow: 0 4px 10px rgba(0,0,0,0.15);
    }

    .cc-link {
        color: #fff !important;
        font-weight: 500;
        padding: 8px 18px;
        border-radius: 12px;
        transition: all 0.25s ease;
    }

    .cc-link:hover {
        background: rgba(255,255,255,0.18);
        transform: translateY(-2px);
        box-shadow: 0 6px 16px rgba(0,0,0,0.2);
    }

    .cc-divider {
        height: 4px;
        background: linear-gradient(90deg, #00ffd0, #4fa3ff, #9f7bff);
        box-shadow: 0 2px 6px rgba(0,0,0,0.15);
    }
    
	    /* Individual button colors */
	.cc-home { background: linear-gradient(135deg, #00c6ff, #0072ff); }
	.cc-rates { background: linear-gradient(135deg, #43e97b, #38f9d7); }
	.cc-currency { background: linear-gradient(135deg, #fa709a, #fee140); }
	.cc-back { background: linear-gradient(135deg, #667eea, #764ba2); }
	
	/* Make text pop */
	.cc-link {
	    color: #fff !important;
	    font-weight: 600;
	    padding: 8px 18px;
	    border-radius: 12px;
	    transition: all 0.25s ease;
	}
	
	/* Hover magic */
	.cc-link:hover {
	    filter: brightness(1.15);
	    transform: translateY(-3px) scale(1.02);
	    box-shadow: 0 8px 20px rgba(0,0,0,0.25);
	}
    
</style>

<nav class="navbar navbar-expand-lg cc-navbar">
    <div class="container-fluid">

        <a class="navbar-brand d-flex align-items-center text-white gap-3" href="convert">
            <img src="logo.png" class="cc-logo" alt="logo">
            <span class="cc-brand">Currency Converter</span>
        </a>

        <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse"
                data-bs-target="#mainNavbar">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse justify-content-end" id="mainNavbar">
            <ul class="navbar-nav align-items-lg-center">
               <li class="nav-item">
				  <a class="nav-link cc-link cc-home" href="convert">Home</a>
				</li>
				<li class="nav-item">
				  <a class="nav-link cc-link cc-rates" href="exchangeRate">Manage Rates</a>
				</li>
				<li class="nav-item">
				  <a class="nav-link cc-link cc-currency" href="currency">Manage Currencies</a>
				</li>
				<li class="nav-item">
				  <a class="nav-link cc-link cc-back" href="login.jsp">Back</a>
				</li>
            </ul>
        </div>

    </div>
</nav>

<div class="cc-divider"></div>
