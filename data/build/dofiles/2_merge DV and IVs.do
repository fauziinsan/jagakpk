
*setting up the environment*

	clear
	set more off
	global suser = c(username)	// define username
	di "$suser"					// check your username

**	Please copy your username and Github local path into the lists of user below:
	* Thoriq (personal laptop)
	if (inlist("${suser}","HP Pavilion Gaming15")) {
			gl github 	"D:\Documents\GitHub\jagakpk\data"
			}
	
	* 
	if (inlist("${suser}","J-PAL SEA")) {
			gl github "C:\Users\J-PAL SEA\Documents\GitHub\jagakpk\data"
			
			}	


**	Globals
gl raw "$github/build/raw"
gl inpath "$github/build/input"
gl outpath "$github/build/output"




** fuzzy matching **
use "$inpath/KorWil_matched_cleaned.dta", clear
gen idnum=_n

preserve
	use "$inpath/Merge unsanitize lama sekolah, garis kemiskinan, kedalaman, keparahan kemiskinan.dta", clear
	gen idnum1=_n
	// different name 
	replace daerah = "Kab. Banyuasin" 			if daerah == "Banyu Asin"
	replace daerah = "Kab. Musi Banyuasin" 			if daerah == "Musi Banyuasin"
	replace daerah = "Kab. Kotabaru" 			if daerah == "Kota Baru"
	replace daerah = "Kab. Nagakeo" 			if daerah == "Nagekeo"
	replace daerah = "Kab. Tulang Bawang" 			if daerah == "Tulangbawang"
	replace daerah = "Kab. Banyumas" 			if daerah == "Banyumas"
	replace daerah = "Kab. Nduga" 			if daerah == "Nduga *"
	tempfile tmp1 
	sa `tmp1'
restore 

*merge
	matchit idnum nama_kabkot using `tmp1', idusing(idnum1) txtusing(daerah) over
	bys nama_kabkot: egen rankscore = rank(similscore)
	bys nama_kabkot: egen maxscore = max(rankscore)
	bys nama_kabkot: keep if maxscore == rankscore
	drop rankscore maxscore
	
	bys daerah: egen rankscore = rank(similscore)
	bys daerah: egen maxscore = max(rankscore)
	bys daerah: keep if maxscore == rankscore
	drop rankscore maxscore
	tempfile tmp2
	sa `tmp2'

merge 1:m nama_kabkot using  "$inpath/KorWil_matched_cleaned.dta"

merge m:1 daerah using "$inpath/Merge unsanitize lama sekolah, garis kemiskinan, kedalaman, keparahan kemiskinan.dta", gen(merge2)

keep if merge2==3

*keep only relevant vars 
keep nama_kabkot area_intervensi nama_prov median_nilai-gap_mean lama_sekolah-indeks_kedalaman_miskin





*save dataset
save "$outpath/cleaned-jaga-foranalysis", replace
