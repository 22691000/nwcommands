*! Date        : 24aug2014
*! Version     : 1.0
*! Author      : Thomas Grund, Link�ping University
*! Email	   : contact@nwcommands.org

capture program drop nwload
program nwload
	syntax [anything(name=loadname)][, id(string) nocurrent xvars labelonly force]

	nwset, nooutput
	
	if ("`id'" == ""){
		_nwsyntax `loadname', max(1)
		local loadname = "`netname'"
		nwname `loadname'
	}
	else {
		nwname, id("`id'")
	}
	local nodes = r(nodes)
	
	if (`nodes' > 1000 & "`force'" == "" & "`labelonly'" == "") {
		exit
	}
	
	if (`=`c(k)' + `nodes'' >= `c(max_k_theory)') {
		exit
	}
	
	scalar onename = "\$nwname_`id'"
	local localname `=onename'
	scalar onevars = "\$nw_`id'"
	local localvars `=onevars'
	scalar onelabs = "\$nwlabs_`id'"
	local locallabs `"`=onelabs'"'
		
		
	if "`labelonly'" != "" {		

		
		capture drop _nodelab
		capture drop _nodeid
		if `=_N' < `nodes' {
			set obs `nodes'
		}
		
		gen _nodelab = ""
		gen _nodeid = _n if _n <= `nodes'
		local j = 1
		foreach lab in `locallabs' {
			qui replace _nodelab = `"`lab'"' in `j'
			local j = `j' + 1
		}
		exit

	}
	
	if (("`xvars'" == "") & ("`labelonly'" == "")){
		capture drop _nodelab
		capture drop _nodevar
		qui mata: st_addvar("str20", "_nodelab")
		qui mata: st_addvar("str20", "_nodevar")
	
		
		if _N < `nodes' {
			set obs `nodes'
		}
		
		local i = 1
		foreach var in `localvars' {
			capture drop `var'
			qui replace _nodevar = "`var'" in `i'
			local i = `i' + 1 
		}
		local j = 1
		foreach lab in `locallabs' {
			qui replace _nodelab = `"`lab'"' in `j'
			local j = `j' + 1
		}
		capture drop _nodeid
		gen _nodeid = _n if _n <= `nodes'
		nwtostata, mat(nw_mata`id') gen(`localvars')
	}
	
	if ("`current'" != "nocurrent") {
		nwcurrent, id(`id')
	}
end
