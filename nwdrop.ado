capture program drop nwdrop
program nwdrop
	version 9
	syntax [anything(name=netname)] [if/], [id(string) netonly attributes(varlist) reverseif]
	_nwsyntax `netname', max(9999)

	local nets `networks'
	local z = 0
	qui foreach dropnet in `netname' {
		nwname `dropnet'
		local id = r(id)
		local nodes = r(nodes)
		local z = `z' + 1
		
		// only drop nodes 
		if ("`if'" != ""){
			tempvar keepnode
			gen `keepnode' = 1
			replace `keepnode' = 0 if `if'
			if ("`reverseif'"!= ""){
				recode `keepnode' (0=1) (1=0)
			}
			mata: keepnode = st_data((1,`nodes'), st_varindex("`keepnode'"))
			
			// WHY DID I INCLUDE THIS? IT MESSES WITH NWPLOT (MDS)
			// make sure that attributes are only included for dropping one network
			//if (`z' != `nets') {
			//	nwdropnodes `dropnet', keepmat(keepnode) `netonly'
			//}
			//else {
				nwdropnodes `dropnet', keepmat(keepnode) `netonly' attributes(`attributes')
			//}
			mata: mata drop keepnode
		}
		
		// drop the whole network
		else {
			// delete Stata variables if needed
			scalar onenw = "\$nw_`id'"
			if "`netonly'" == "" {
				capture confirm variable `=onenw'
				if _rc == 0 {
					qui drop `=onenw'
				}
				capture drop _label	 
			}
	
			// update all Stata/Mata macros
			local k 	= $nwtotal - 1
			forvalues j = `id'/`k' {
				local next = `j' + 1
				nwname, id(`next')
				global nwname_`j' = r(name)
				global nwsize_`j' = r(nodes)
				global nwdirected_`j' = r(directed)			
		
				scalar movenw = "\$nw_`next'"
				global nw_`j' `=movenw'
				
				mata: mata drop nw_mata`j'
				mata: nw_mata`j' = nw_mata`next'
			}
			
			// clean-up
			macro drop nw_$nwtotal
			macro drop nwsize_$nwtotal
			macro drop nwname_$nwtotal
			macro drop nwdirected_$nwtotal
			macro drop nwlabs_$nwtotal
			macro drop nwedgelabs_$nwtotal
			mata: mata drop nw_mata$nwtotal
			global nwtotal `=$nwtotal - 1'
			global nwtotal_mata = `=$nwtotal_mata - 1'
		}
	}
	nwcompressobs
	mata: st_rclear()
end
	
	
	