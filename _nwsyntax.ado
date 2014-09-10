*! Date        : 10sept2014
*! Version     : 1.1.0
*! Author      : Thomas Grund, Link�ping University
*! Email	   : contact@nwcommands.org

capture program drop _nwsyntax
program _nwsyntax
	syntax [anything],[max(integer 1) min(passthru) nocurrent name(string) id(string)]
	if "`name'" == "" {
		local name = "netname"
	}
	if "`id'" == "" {
		local id = "id"
	}
	local netname = "`name'"
	local netid = "`id'"
	
	if "`anything'" == ""  & "`current'" == ""{
		nwcurrent
		local anything = r(current)
	}
	
	capture nwunab _temp : `anything', max(`max') `min'
	if _rc != 0 {
		if _rc == 111 {
			di "{err}network `anything' not found"
		}
		if _rc == 102 {
			di "{err}`anything'"
			di "too few networks specified"
		}
		if _rc == 103 {
			di "{err}`anything'"
			di "too many networks specified"
		}
	}
	
	local networks `r(networks)'
	local lastnet : word `networks' of `_temp'
	mata: st_rclear()
	
	nwname `lastnet'
	local id = r(id)
	mata: _diag(nw_mata`id', 0)
	
	c_local id "`r(id)'"		
	c_local `netname' "`_temp'"
	c_local nodes "`r(nodes)'"
	c_local `name' "`r(name)'"
	c_local directed "`r(directed)'"
	c_local networks "`networks'"
	
	
end

