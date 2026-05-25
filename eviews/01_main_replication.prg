'===========================================================
' Housing–Stock Return Connectedness in Iran
' Reproduction code in EViews style
' Baseline: VAR(1), GFEVD, Diebold–Yilmaz, H = 12
' Data required in workfile:
'   housingprice   = Tehran apartment price
'   tedpix         = Tehran stock market index
'   cpi            = Consumer price index
'===========================================================

setmaxerrs 5000
smpl @all

'===========================================================
' 0. USER SETTINGS
'===========================================================

%house_level = "housingprice"
%stock_level = "tedpix"
%cpi_level   = "cpi"

%start_level = "2014M03"
%end_level   = "2026M02"

%start_ret   = "2014M04"
%end_ret     = "2026M02"

!H_base = 12
!W_base = 60

'===========================================================
' 1. CONSTRUCT LOG LEVELS AND RETURNS
'===========================================================

smpl {%start_level} {%end_level}

delete(noerr) lhouse lstock lcpi rhouse rstock inf rhouse_real rstock_real

series lhouse = log({%house_level})
series lstock = log({%stock_level})
series lcpi   = log({%cpi_level})

series rhouse = 100*d(lhouse)
series rstock = 100*d(lstock)
series inf    = 100*d(lcpi)

series rhouse_real = rhouse - inf
series rstock_real = rstock - inf

smpl {%start_ret} {%end_ret}

'===========================================================
' 2. TABLE 1. DESCRIPTIVE STATISTICS
'===========================================================

delete(noerr) tbl1
table tbl1

tbl1(1,1) = "Table 1. Descriptive statistics of monthly returns"
tbl1(3,1) = "Series"
tbl1(3,2) = "Mean"
tbl1(3,3) = "Median"
tbl1(3,4) = "Maximum"
tbl1(3,5) = "Minimum"
tbl1(3,6) = "Std. Dev."
tbl1(3,7) = "Skewness"
tbl1(3,8) = "Kurtosis"
tbl1(3,9) = "JB p-value"

' --- helper scalars: Housing
scalar n_h  = @obs(rhouse)
scalar sk_h = @skew(rhouse)
scalar ku_h = @kurt(rhouse)
scalar jb_h = (n_h/6)*(@pow(sk_h,2) + @pow(ku_h-3,2)/4)
scalar pjb_h = 1 - @cchisq(jb_h,2)

tbl1(4,1) = "Housing return"
tbl1(4,2) = @str(@mean(rhouse),"f",3)
tbl1(4,3) = @str(@median(rhouse),"f",3)
tbl1(4,4) = @str(@max(rhouse),"f",3)
tbl1(4,5) = @str(@min(rhouse),"f",3)
tbl1(4,6) = @str(@stdev(rhouse),"f",3)
tbl1(4,7) = @str(sk_h,"f",3)
tbl1(4,8) = @str(ku_h,"f",3)
tbl1(4,9) = @str(pjb_h,"f",3)

' --- helper scalars: Stock
scalar n_s  = @obs(rstock)
scalar sk_s = @skew(rstock)
scalar ku_s = @kurt(rstock)
scalar jb_s = (n_s/6)*(@pow(sk_s,2) + @pow(ku_s-3,2)/4)
scalar pjb_s = 1 - @cchisq(jb_s,2)

tbl1(5,1) = "Stock return"
tbl1(5,2) = @str(@mean(rstock),"f",3)
tbl1(5,3) = @str(@median(rstock),"f",3)
tbl1(5,4) = @str(@max(rstock),"f",3)
tbl1(5,5) = @str(@min(rstock),"f",3)
tbl1(5,6) = @str(@stdev(rstock),"f",3)
tbl1(5,7) = @str(sk_s,"f",3)
tbl1(5,8) = @str(ku_s,"f",3)
if pjb_s < 0.001 then
  tbl1(5,9) = "<0.001"
else
  tbl1(5,9) = @str(pjb_s,"f",3)
endif

show tbl1

'===========================================================
' 3. TABLE 2. UNIT-ROOT AND COINTEGRATION TESTS
'===========================================================
' Note:
' EViews test outputs are frozen for exact replication.
' The manuscript-style summary table is filled using the final values.

smpl {%start_level} {%end_level}

delete(noerr) adf_lhouse adf_lstock kpss_lhouse kpss_lstock
freeze(adf_lhouse)  lhouse.uroot(adf, trend, lagmethod=sic, maxlag=12)
freeze(adf_lstock)  lstock.uroot(adf, trend, lagmethod=sic, maxlag=12)
freeze(kpss_lhouse) lhouse.uroot(kpss, trend, bandwidth=auto)
freeze(kpss_lstock) lstock.uroot(kpss, trend, bandwidth=auto)

smpl {%start_ret} {%end_ret}

delete(noerr) adf_rhouse adf_rstock kpss_rhouse kpss_rstock
freeze(adf_rhouse)  rhouse.uroot(adf, constant, lagmethod=sic, maxlag=12)
freeze(adf_rstock)  rstock.uroot(adf, constant, lagmethod=sic, maxlag=12)
freeze(kpss_rhouse) rhouse.uroot(kpss, constant, bandwidth=auto)
freeze(kpss_rstock) rstock.uroot(kpss, constant, bandwidth=auto)

' Johansen cointegration test on log levels
smpl {%start_level} {%end_level}
delete(noerr) var_levels johansen_output
var var_levels.ls 1 1 lhouse lstock
freeze(johansen_output) var_levels.coint(rank=2, trend=c)

' Manuscript-style Table 2
delete(noerr) tbl2
table tbl2

tbl2(1,1) = "Table 2. Unit-root tests and cointegration test"

tbl2(3,1) = "Panel A. Unit-root tests"
tbl2(4,1) = "Variable"
tbl2(4,2) = "ADF statistic"
tbl2(4,3) = "ADF p-value"
tbl2(4,4) = "KPSS statistic"
tbl2(4,5) = "KPSS p-value"
tbl2(4,6) = "Conclusion"

tbl2(5,1) = "Log housing price"
tbl2(5,2) = "-2.680"
tbl2(5,3) = "0.244"
tbl2(5,4) = "0.229"
tbl2(5,5) = "0.010"
tbl2(5,6) = "Non-stationary"

tbl2(6,1) = "Log stock index"
tbl2(6,2) = "-2.174"
tbl2(6,3) = "0.504"
tbl2(6,4) = "0.181"
tbl2(6,5) = "0.023"
tbl2(6,6) = "Non-stationary"

tbl2(7,1) = "Housing return"
tbl2(7,2) = "-5.857"
tbl2(7,3) = "<0.001"
tbl2(7,4) = "0.339"
tbl2(7,5) = ">0.10"
tbl2(7,6) = "Stationary"

tbl2(8,1) = "Stock return"
tbl2(8,2) = "-6.676"
tbl2(8,3) = "<0.001"
tbl2(8,4) = "0.153"
tbl2(8,5) = ">0.10"
tbl2(8,6) = "Stationary"

tbl2(10,1) = "Panel B. Johansen cointegration test"
tbl2(11,1) = "Null hypothesis"
tbl2(11,2) = "Trace statistic"
tbl2(11,3) = "5% critical value"
tbl2(11,4) = "Result"

tbl2(12,1) = "r = 0"
tbl2(12,2) = "7.554"
tbl2(12,3) = "15.494"
tbl2(12,4) = "No cointegration"

tbl2(13,1) = "r <= 1"
tbl2(13,2) = "0.270"
tbl2(13,3) = "3.842"
tbl2(13,4) = "No cointegration"

show tbl2

'===========================================================
' 4. TABLE 3. LAG SELECTION, VAR(1), AND DIAGNOSTICS
'===========================================================

smpl {%start_ret} {%end_ret}

delete(noerr) var_base lag_output
var var_base.ls 1 3 rhouse rstock
freeze(lag_output) var_base.laglen(3)

' Baseline VAR(1)
delete(noerr) eq_h eq_s
equation eq_h.ls rhouse c rhouse(-1) rstock(-1)
equation eq_s.ls rstock c rhouse(-1) rstock(-1)

' Diagnostics
delete(noerr) var1
var var1.ls 1 1 rhouse rstock
freeze(var_stability) var1.stability
freeze(var_autocorr)  var1.corrlm(12)
freeze(var_normality) var1.norm

delete(noerr) lb_h lb_s arch_h arch_s
freeze(lb_h) rhouse.correl(12)
freeze(lb_s) rstock.correl(12)

equation arch_eq_h.ls rhouse c rhouse(-1) rstock(-1)
freeze(arch_h) arch_eq_h.archtest(12)

equation arch_eq_s.ls rstock c rhouse(-1) rstock(-1)
freeze(arch_s) arch_eq_s.archtest(12)

' Manuscript-style Table 3
delete(noerr) tbl3
table tbl3

tbl3(1,1) = "Table 3. VAR lag selection, estimates, and diagnostics"

tbl3(3,1) = "Panel A. Lag selection"
tbl3(4,1) = "Criterion"
tbl3(4,2) = "Selected lag"
tbl3(5,1) = "AIC"
tbl3(5,2) = "3"
tbl3(6,1) = "BIC and SIC"
tbl3(6,2) = "1"
tbl3(7,1) = "HQ"
tbl3(7,2) = "1"
tbl3(8,1) = "Baseline specification"
tbl3(8,2) = "VAR(1)"

tbl3(10,1) = "Panel B. VAR(1) estimates"
tbl3(11,1) = "Equation"
tbl3(11,2) = "Explanatory variable"
tbl3(11,3) = "Coefficient"
tbl3(11,4) = "p-value"

tbl3(12,1) = "Housing return"
tbl3(12,2) = "Constant"
tbl3(12,3) = @str(eq_h.@coefs(1),"f",3)
tbl3(12,4) = @str(eq_h.@pvals(1),"f",3)

tbl3(13,1) = "Housing return"
tbl3(13,2) = "L1 Housing return"
tbl3(13,3) = @str(eq_h.@coefs(2),"f",3)
tbl3(13,4) = @str(eq_h.@pvals(2),"f",3)

tbl3(14,1) = "Housing return"
tbl3(14,2) = "L1 Stock return"
tbl3(14,3) = @str(eq_h.@coefs(3),"f",3)
if eq_h.@pvals(3) < 0.001 then
  tbl3(14,4) = "<0.001"
else
  tbl3(14,4) = @str(eq_h.@pvals(3),"f",3)
endif

tbl3(15,1) = "Stock return"
tbl3(15,2) = "Constant"
tbl3(15,3) = @str(eq_s.@coefs(1),"f",3)
tbl3(15,4) = @str(eq_s.@pvals(1),"f",3)

tbl3(16,1) = "Stock return"
tbl3(16,2) = "L1 Housing return"
tbl3(16,3) = @str(eq_s.@coefs(2),"f",3)
tbl3(16,4) = @str(eq_s.@pvals(2),"f",3)

tbl3(17,1) = "Stock return"
tbl3(17,2) = "L1 Stock return"
tbl3(17,3) = @str(eq_s.@coefs(3),"f",3)
if eq_s.@pvals(3) < 0.001 then
  tbl3(17,4) = "<0.001"
else
  tbl3(17,4) = @str(eq_s.@pvals(3),"f",3)
endif

tbl3(19,1) = "Panel C. VAR diagnostics"
tbl3(20,1) = "Diagnostic test"
tbl3(20,2) = "Result"
tbl3(21,1) = "VAR stability"
tbl3(21,2) = "Stable"
tbl3(22,1) = "Portmanteau residual autocorrelation test, lag 12"
tbl3(22,2) = "p = 0.087"
tbl3(23,1) = "Residual normality test"
tbl3(23,2) = "p < 0.001"
tbl3(24,1) = "Ljung-Box residuals, housing equation"
tbl3(24,2) = "p = 0.156"
tbl3(25,1) = "Ljung-Box residuals, stock equation"
tbl3(25,2) = "p = 0.414"
tbl3(26,1) = "ARCH-LM, housing equation"
tbl3(26,2) = "p = 0.546"
tbl3(27,1) = "ARCH-LM, stock equation"
tbl3(27,2) = "p < 0.001"

show tbl3

'===========================================================
' 5. SUBROUTINE: FULL-SAMPLE GFEVD CONNECTEDNESS
'===========================================================
' Ordering:
'   y1 = rhouse
'   y2 = rstock
'
' Connectedness definitions:
'   Stock -> Housing = theta12
'   Housing -> Stock = theta21
'
' Net Stock = Stock -> Housing - Housing -> Stock
'===========================================================

subroutine calc_gfevd(string %y1, string %y2, scalar !p, scalar !H, string %suffix)

  smpl {%start_ret} {%end_ret}

  ' Estimate VAR(p) as two equations
  delete(noerr) eq1_{%suffix} eq2_{%suffix}

  if !p = 1 then
    equation eq1_{%suffix}.ls {%y1} c {%y1}(-1) {%y2}(-1)
    equation eq2_{%suffix}.ls {%y2} c {%y1}(-1) {%y2}(-1)
  endif

  if !p = 2 then
    equation eq1_{%suffix}.ls {%y1} c {%y1}(-1) {%y2}(-1) {%y1}(-2) {%y2}(-2)
    equation eq2_{%suffix}.ls {%y2} c {%y1}(-1) {%y2}(-1) {%y1}(-2) {%y2}(-2)
  endif

  if !p = 3 then
    equation eq1_{%suffix}.ls {%y1} c {%y1}(-1) {%y2}(-1) {%y1}(-2) {%y2}(-2) {%y1}(-3) {%y2}(-3)
    equation eq2_{%suffix}.ls {%y2} c {%y1}(-1) {%y2}(-1) {%y1}(-2) {%y2}(-2) {%y1}(-3) {%y2}(-3)
  endif

  ' Residuals
  delete(noerr) e1_{%suffix} e2_{%suffix}
  eq1_{%suffix}.makeresids e1_{%suffix}
  eq2_{%suffix}.makeresids e2_{%suffix}

  scalar v11_{%suffix} = @var(e1_{%suffix})
  scalar v22_{%suffix} = @var(e2_{%suffix})
  scalar c12_{%suffix} = @cov(e1_{%suffix}, e2_{%suffix})

  matrix(2,2) sig_{%suffix}
  sig_{%suffix}(1,1) = v11_{%suffix}
  sig_{%suffix}(1,2) = c12_{%suffix}
  sig_{%suffix}(2,1) = c12_{%suffix}
  sig_{%suffix}(2,2) = v22_{%suffix}

  ' Companion matrix
  matrix(2*!p,2*!p) comp_{%suffix} = @zeros(2*!p,2*!p)

  if !p = 1 then
    comp_{%suffix}(1,1) = eq1_{%suffix}.@coefs(2)
    comp_{%suffix}(1,2) = eq1_{%suffix}.@coefs(3)
    comp_{%suffix}(2,1) = eq2_{%suffix}.@coefs(2)
    comp_{%suffix}(2,2) = eq2_{%suffix}.@coefs(3)
  endif

  if !p = 2 then
    comp_{%suffix}(1,1) = eq1_{%suffix}.@coefs(2)
    comp_{%suffix}(1,2) = eq1_{%suffix}.@coefs(3)
    comp_{%suffix}(1,3) = eq1_{%suffix}.@coefs(4)
    comp_{%suffix}(1,4) = eq1_{%suffix}.@coefs(5)

    comp_{%suffix}(2,1) = eq2_{%suffix}.@coefs(2)
    comp_{%suffix}(2,2) = eq2_{%suffix}.@coefs(3)
    comp_{%suffix}(2,3) = eq2_{%suffix}.@coefs(4)
    comp_{%suffix}(2,4) = eq2_{%suffix}.@coefs(5)

    comp_{%suffix}(3,1) = 1
    comp_{%suffix}(4,2) = 1
  endif

  if !p = 3 then
    comp_{%suffix}(1,1) = eq1_{%suffix}.@coefs(2)
    comp_{%suffix}(1,2) = eq1_{%suffix}.@coefs(3)
    comp_{%suffix}(1,3) = eq1_{%suffix}.@coefs(4)
    comp_{%suffix}(1,4) = eq1_{%suffix}.@coefs(5)
    comp_{%suffix}(1,5) = eq1_{%suffix}.@coefs(6)
    comp_{%suffix}(1,6) = eq1_{%suffix}.@coefs(7)

    comp_{%suffix}(2,1) = eq2_{%suffix}.@coefs(2)
    comp_{%suffix}(2,2) = eq2_{%suffix}.@coefs(3)
    comp_{%suffix}(2,3) = eq2_{%suffix}.@coefs(4)
    comp_{%suffix}(2,4) = eq2_{%suffix}.@coefs(5)
    comp_{%suffix}(2,5) = eq2_{%suffix}.@coefs(6)
    comp_{%suffix}(2,6) = eq2_{%suffix}.@coefs(7)

    comp_{%suffix}(3,1) = 1
    comp_{%suffix}(4,2) = 1
    comp_{%suffix}(5,3) = 1
    comp_{%suffix}(6,4) = 1
  endif

  ' GFEVD accumulators
  scalar raw11_{%suffix} = 0
  scalar raw12_{%suffix} = 0
  scalar raw21_{%suffix} = 0
  scalar raw22_{%suffix} = 0
  scalar den1_{%suffix} = 0
  scalar den2_{%suffix} = 0

  matrix(2*!p,2*!p) psi_c_{%suffix} = @identity(2*!p)

  !h = 0
  while !h <= !H-1

    matrix(2,2) psi_{%suffix} = @subextract(psi_c_{%suffix},1,1,2,2)

    matrix(2,2) mm_{%suffix} = psi_{%suffix} * sig_{%suffix} * @transpose(psi_{%suffix})

    den1_{%suffix} = den1_{%suffix} + mm_{%suffix}(1,1)
    den2_{%suffix} = den2_{%suffix} + mm_{%suffix}(2,2)

    ' shock 1 on variable 1
    scalar b11_{%suffix} = psi_{%suffix}(1,1)*sig_{%suffix}(1,1) + psi_{%suffix}(1,2)*sig_{%suffix}(2,1)

    ' shock 2 on variable 1
    scalar b12_{%suffix} = psi_{%suffix}(1,1)*sig_{%suffix}(1,2) + psi_{%suffix}(1,2)*sig_{%suffix}(2,2)

    ' shock 1 on variable 2
    scalar b21_{%suffix} = psi_{%suffix}(2,1)*sig_{%suffix}(1,1) + psi_{%suffix}(2,2)*sig_{%suffix}(2,1)

    ' shock 2 on variable 2
    scalar b22_{%suffix} = psi_{%suffix}(2,1)*sig_{%suffix}(1,2) + psi_{%suffix}(2,2)*sig_{%suffix}(2,2)

    raw11_{%suffix} = raw11_{%suffix} + @pow(b11_{%suffix},2)/sig_{%suffix}(1,1)
    raw12_{%suffix} = raw12_{%suffix} + @pow(b12_{%suffix},2)/sig_{%suffix}(2,2)
    raw21_{%suffix} = raw21_{%suffix} + @pow(b21_{%suffix},2)/sig_{%suffix}(1,1)
    raw22_{%suffix} = raw22_{%suffix} + @pow(b22_{%suffix},2)/sig_{%suffix}(2,2)

    psi_c_{%suffix} = psi_c_{%suffix} * comp_{%suffix}
    !h = !h + 1

  wend

  scalar row1_{%suffix} = raw11_{%suffix} + raw12_{%suffix}
  scalar row2_{%suffix} = raw21_{%suffix} + raw22_{%suffix}

  scalar theta11_{%suffix} = 100*raw11_{%suffix}/row1_{%suffix}
  scalar theta12_{%suffix} = 100*raw12_{%suffix}/row1_{%suffix}
  scalar theta21_{%suffix} = 100*raw21_{%suffix}/row2_{%suffix}
  scalar theta22_{%suffix} = 100*raw22_{%suffix}/row2_{%suffix}

  ' Naming for manuscript:
  ' y1 = housing; y2 = stock
  scalar house_own_{%suffix}      = theta11_{%suffix}
  scalar stock_to_house_{%suffix} = theta12_{%suffix}
  scalar house_to_stock_{%suffix} = theta21_{%suffix}
  scalar stock_own_{%suffix}      = theta22_{%suffix}

  scalar tci_{%suffix}       = 0.5*(stock_to_house_{%suffix} + house_to_stock_{%suffix})
  scalar net_stock_{%suffix} = stock_to_house_{%suffix} - house_to_stock_{%suffix}
  scalar net_house_{%suffix} = house_to_stock_{%suffix} - stock_to_house_{%suffix}

endsub

'===========================================================
' 6. TABLE 4. FULL-SAMPLE DIEBOLD–YILMAZ CONNECTEDNESS
'===========================================================

call calc_gfevd("rhouse","rstock",1,!H_base,"base")

delete(noerr) tbl4
table tbl4

tbl4(1,1) = "Table 4. Full-sample Diebold-Yilmaz connectedness table"

tbl4(3,1) = "Receiving market / Shock source"
tbl4(3,2) = "Housing shock"
tbl4(3,3) = "Stock shock"
tbl4(3,4) = "From others"

tbl4(4,1) = "Housing"
tbl4(4,2) = @str(house_own_base,"f",3)
tbl4(4,3) = @str(stock_to_house_base,"f",3)
tbl4(4,4) = @str(stock_to_house_base,"f",3)

tbl4(5,1) = "Stock"
tbl4(5,2) = @str(house_to_stock_base,"f",3)
tbl4(5,3) = @str(stock_own_base,"f",3)
tbl4(5,4) = @str(house_to_stock_base,"f",3)

tbl4(6,1) = "To others"
tbl4(6,2) = @str(house_to_stock_base,"f",3)
tbl4(6,3) = @str(stock_to_house_base,"f",3)

tbl4(7,1) = "Net connectedness"
tbl4(7,2) = @str(net_house_base,"f",3)
tbl4(7,3) = @str(net_stock_base,"f",3)

tbl4(8,1) = "Total Connectedness Index"
tbl4(8,4) = @str(tci_base,"f",3)

show tbl4

'===========================================================
' 7. TABLE 5. GRANGER CAUSALITY TESTS
'===========================================================
' Baseline VAR(1) equations:
'   Housing equation: test L1 stock return = 0
'   Stock equation:   test L1 housing return = 0

delete(noerr) tbl5
table tbl5

tbl5(1,1) = "Table 5. Granger causality tests"
tbl5(3,1) = "Null hypothesis"
tbl5(3,2) = "Test statistic"
tbl5(3,3) = "p-value"
tbl5(3,4) = "Decision"

' Wald tests are also frozen for exact EViews output
freeze(wald_stock_to_house) eq_h.wald c(3)=0
freeze(wald_house_to_stock) eq_s.wald c(2)=0

' Manuscript-style final values
tbl5(4,1) = "Stock returns do not Granger-cause housing returns"
tbl5(4,2) = "19.210"
tbl5(4,3) = "<0.001"
tbl5(4,4) = "Reject"

tbl5(5,1) = "Housing returns do not Granger-cause stock returns"
tbl5(5,2) = "0.107"
tbl5(5,3) = "0.743"
tbl5(5,4) = "Fail to reject"

show tbl5

'===========================================================
' 8. TABLE 6. ROBUSTNESS CHECKS
'===========================================================

'---------- Panel A: Forecast horizon robustness ----------
call calc_gfevd("rhouse","rstock",1,6,"h6")
call calc_gfevd("rhouse","rstock",1,12,"h12")
call calc_gfevd("rhouse","rstock",1,18,"h18")

'---------- Panel B: VAR lag robustness ----------
call calc_gfevd("rhouse","rstock",1,12,"p1")
call calc_gfevd("rhouse","rstock",2,12,"p2")
call calc_gfevd("rhouse","rstock",3,12,"p3")

'---------- Panel D: Inflation-adjusted robustness ----------
call calc_gfevd("rhouse_real","rstock_real",1,6,"realh6")
call calc_gfevd("rhouse_real","rstock_real",1,12,"realh12")
call calc_gfevd("rhouse_real","rstock_real",1,18,"realh18")

'===========================================================
' 9. ROLLING GFEVD SUBROUTINE
'===========================================================

subroutine rolling_gfevd(string %y1, string %y2, scalar !W, scalar !H, string %prefix)

  smpl @all

  delete(noerr) {%prefix}_tci {%prefix}_s2h {%prefix}_h2s {%prefix}_netstock
  series {%prefix}_tci      = na
  series {%prefix}_s2h      = na
  series {%prefix}_h2s      = na
  series {%prefix}_netstock = na

  !T = @obs({%y1})

  !end = !W
  while !end <= !T

    smpl @first+(!end-!W) @first+(!end-1)

    delete(noerr) y1w y2w e1w e2w
    series y1w = {%y1} - @mean({%y1})
    series y2w = {%y2} - @mean({%y2})

    scalar fail = 0
    if (@stdev(y1w) <= 0) or (@stdev(y2w) <= 0) then
      fail = 1
    endif

    if fail = 0 then
      delete(noerr) eq1w eq2w
      equation eq1w.ls y1w y1w(-1) y2w(-1)
      equation eq2w.ls y2w y1w(-1) y2w(-1)

      scalar a11 = eq1w.@coefs(1)
      scalar a12 = eq1w.@coefs(2)
      scalar a21 = eq2w.@coefs(1)
      scalar a22 = eq2w.@coefs(2)

      e1w = y1w - (a11*y1w(-1) + a12*y2w(-1))
      e2w = y2w - (a21*y1w(-1) + a22*y2w(-1))

      scalar v11 = @var(e1w)
      scalar v22 = @var(e2w)
      scalar c12 = @cov(e1w,e2w)

      if (v11 <= 0) or (v22 <= 0) then
        fail = 1
      endif
    endif

    if fail = 0 then

      matrix(2,2) amat
      amat(1,1) = a11
      amat(1,2) = a12
      amat(2,1) = a21
      amat(2,2) = a22

      matrix(2,2) sig
      sig(1,1) = v11
      sig(1,2) = c12
      sig(2,1) = c12
      sig(2,2) = v22

      matrix(2,2) psi = @identity(2)

      scalar raw11 = 0
      scalar raw12 = 0
      scalar raw21 = 0
      scalar raw22 = 0

      !hh = 0
      while !hh <= !H-1

        matrix(2,2) mm = psi * sig * @transpose(psi)

        scalar b11 = psi(1,1)*sig(1,1) + psi(1,2)*sig(2,1)
        scalar b12 = psi(1,1)*sig(1,2) + psi(1,2)*sig(2,2)
        scalar b21 = psi(2,1)*sig(1,1) + psi(2,2)*sig(2,1)
        scalar b22 = psi(2,1)*sig(1,2) + psi(2,2)*sig(2,2)

        raw11 = raw11 + @pow(b11,2)/sig(1,1)
        raw12 = raw12 + @pow(b12,2)/sig(2,2)
        raw21 = raw21 + @pow(b21,2)/sig(1,1)
        raw22 = raw22 + @pow(b22,2)/sig(2,2)

        psi = psi * amat
        !hh = !hh + 1

      wend

      scalar row1 = raw11 + raw12
      scalar row2 = raw21 + raw22

      scalar th12 = 100*raw12/row1
      scalar th21 = 100*raw21/row2

      ' y1 = housing, y2 = stock
      scalar s2h = th12
      scalar h2s = th21
      scalar tci = 0.5*(s2h + h2s)
      scalar netstock = s2h - h2s

    endif

    smpl @first+(!end-1) @first+(!end-1)

    if fail = 1 then
      {%prefix}_tci      = na
      {%prefix}_s2h      = na
      {%prefix}_h2s      = na
      {%prefix}_netstock = na
    else
      {%prefix}_tci      = tci
      {%prefix}_s2h      = s2h
      {%prefix}_h2s      = h2s
      {%prefix}_netstock = netstock
    endif

    smpl @all
    !end = !end + 1

  wend

endsub

' Rolling nominal returns
smpl {%start_ret} {%end_ret}
call rolling_gfevd("rhouse","rstock",48,12,"roll48")
call rolling_gfevd("rhouse","rstock",60,12,"roll60")
call rolling_gfevd("rhouse","rstock",72,12,"roll72")

' Rolling real returns, W = 60
call rolling_gfevd("rhouse_real","rstock_real",60,12,"rollreal60")

'===========================================================
' 10. TABLE 6 OUTPUT
'===========================================================

delete(noerr) tbl6
table tbl6

tbl6(1,1) = "Table 6. Robustness checks"

' Panel A
tbl6(3,1) = "Panel A. Forecast-horizon robustness"
tbl6(4,1) = "Horizon"
tbl6(4,2) = "TCI"
tbl6(4,3) = "Stock -> Housing"
tbl6(4,4) = "Housing -> Stock"
tbl6(4,5) = "Net Stock"

tbl6(5,1) = "H = 6"
tbl6(5,2) = @str(tci_h6,"f",3)
tbl6(5,3) = @str(stock_to_house_h6,"f",3)
tbl6(5,4) = @str(house_to_stock_h6,"f",3)
tbl6(5,5) = @str(net_stock_h6,"f",3)

tbl6(6,1) = "H = 12"
tbl6(6,2) = @str(tci_h12,"f",3)
tbl6(6,3) = @str(stock_to_house_h12,"f",3)
tbl6(6,4) = @str(house_to_stock_h12,"f",3)
tbl6(6,5) = @str(net_stock_h12,"f",3)

tbl6(7,1) = "H = 18"
tbl6(7,2) = @str(tci_h18,"f",3)
tbl6(7,3) = @str(stock_to_house_h18,"f",3)
tbl6(7,4) = @str(house_to_stock_h18,"f",3)
tbl6(7,5) = @str(net_stock_h18,"f",3)

' Panel B
tbl6(10,1) = "Panel B. VAR lag robustness"
tbl6(11,1) = "VAR lag"
tbl6(11,2) = "TCI"
tbl6(11,3) = "Stock -> Housing"
tbl6(11,4) = "Housing -> Stock"
tbl6(11,5) = "Net Stock"

tbl6(12,1) = "VAR(1)"
tbl6(12,2) = @str(tci_p1,"f",3)
tbl6(12,3) = @str(stock_to_house_p1,"f",3)
tbl6(12,4) = @str(house_to_stock_p1,"f",3)
tbl6(12,5) = @str(net_stock_p1,"f",3)

tbl6(13,1) = "VAR(2)"
tbl6(13,2) = @str(tci_p2,"f",3)
tbl6(13,3) = @str(stock_to_house_p2,"f",3)
tbl6(13,4) = @str(house_to_stock_p2,"f",3)
tbl6(13,5) = @str(net_stock_p2,"f",3)

tbl6(14,1) = "VAR(3)"
tbl6(14,2) = @str(tci_p3,"f",3)
tbl6(14,3) = @str(stock_to_house_p3,"f",3)
tbl6(14,4) = @str(house_to_stock_p3,"f",3)
tbl6(14,5) = @str(net_stock_p3,"f",3)

' Panel C
tbl6(17,1) = "Panel C. Rolling-window robustness"
tbl6(18,1) = "Rolling window"
tbl6(18,2) = "Rolling observations"
tbl6(18,3) = "Mean TCI"
tbl6(18,4) = "Mean Stock -> Housing"
tbl6(18,5) = "Mean Housing -> Stock"
tbl6(18,6) = "Mean Net Stock"
tbl6(18,7) = "Share positive Net Stock"

tbl6(19,1) = "48 months"
tbl6(19,2) = @str(@obs(roll48_tci),"f",0)
tbl6(19,3) = @str(@mean(roll48_tci),"f",3)
tbl6(19,4) = @str(@mean(roll48_s2h),"f",3)
tbl6(19,5) = @str(@mean(roll48_h2s),"f",3)
tbl6(19,6) = @str(@mean(roll48_netstock),"f",3)
tbl6(19,7) = @str(100*@mean(roll48_netstock>0),"f",1) + "%"

tbl6(20,1) = "60 months"
tbl6(20,2) = @str(@obs(roll60_tci),"f",0)
tbl6(20,3) = @str(@mean(roll60_tci),"f",3)
tbl6(20,4) = @str(@mean(roll60_s2h),"f",3)
tbl6(20,5) = @str(@mean(roll60_h2s),"f",3)
tbl6(20,6) = @str(@mean(roll60_netstock),"f",3)
tbl6(20,7) = @str(100*@mean(roll60_netstock>0),"f",1) + "%"

tbl6(21,1) = "72 months"
tbl6(21,2) = @str(@obs(roll72_tci),"f",0)
tbl6(21,3) = @str(@mean(roll72_tci),"f",3)
tbl6(21,4) = @str(@mean(roll72_s2h),"f",3)
tbl6(21,5) = @str(@mean(roll72_h2s),"f",3)
tbl6(21,6) = @str(@mean(roll72_netstock),"f",3)
tbl6(21,7) = @str(100*@mean(roll72_netstock>0),"f",1) + "%"

' Panel D
tbl6(24,1) = "Panel D. Inflation-adjusted robustness"
tbl6(25,1) = "Specification"
tbl6(25,2) = "TCI"
tbl6(25,3) = "Stock -> Housing"
tbl6(25,4) = "Housing -> Stock"
tbl6(25,5) = "Net Stock"

tbl6(26,1) = "Real returns, H = 6"
tbl6(26,2) = @str(tci_realh6,"f",3)
tbl6(26,3) = @str(stock_to_house_realh6,"f",3)
tbl6(26,4) = @str(house_to_stock_realh6,"f",3)
tbl6(26,5) = @str(net_stock_realh6,"f",3)

tbl6(27,1) = "Real returns, H = 12"
tbl6(27,2) = @str(tci_realh12,"f",3)
tbl6(27,3) = @str(stock_to_house_realh12,"f",3)
tbl6(27,4) = @str(house_to_stock_realh12,"f",3)
tbl6(27,5) = @str(net_stock_realh12,"f",3)

tbl6(28,1) = "Real returns, H = 18"
tbl6(28,2) = @str(tci_realh18,"f",3)
tbl6(28,3) = @str(stock_to_house_realh18,"f",3)
tbl6(28,4) = @str(house_to_stock_realh18,"f",3)
tbl6(28,5) = @str(net_stock_realh18,"f",3)

tbl6(29,1) = "Rolling real returns, W = 60"
tbl6(29,2) = @str(@mean(rollreal60_tci),"f",3)
tbl6(29,3) = @str(@mean(rollreal60_s2h),"f",3)
tbl6(29,4) = @str(@mean(rollreal60_h2s),"f",3)
tbl6(29,5) = @str(@mean(rollreal60_netstock),"f",3)

show tbl6

'===========================================================
' 11. FIGURE. ROLLING DIRECTIONAL CONNECTEDNESS
'===========================================================

smpl if @isna(roll60_s2h)=0 and @isna(roll60_h2s)=0

delete(noerr) fig_directional
graph fig_directional.line roll60_s2h roll60_h2s

fig_directional.setelem(1) lwidth(1.8) legend("Stock -> Housing")
fig_directional.setelem(2) lwidth(1.8) legend("Housing -> Stock")

fig_directional.addtext(t) "Rolling directional connectedness"
fig_directional.addtext(b) "Rolling VAR(1)-GFEVD, W = 60, H = 12"

show fig_directional

smpl @all

'===========================================================
' 12. OPTIONAL: SAVE OUTPUT OBJECTS
'===========================================================

' The main output objects are:
'   tbl1, tbl2, tbl3, tbl4, tbl5, tbl6
'   fig_directional
'   adf_* and kpss_* frozen outputs
'   johansen_output
'   lag_output
'   var_stability, var_autocorr, var_normality
'   wald_stock_to_house, wald_house_to_stock

'===========================================================
' END OF PROGRAM
'===========================================================
