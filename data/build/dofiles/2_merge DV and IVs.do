
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
	use "$inpath/district_chars.dta", clear
	gen idnum1=_n
	// different name 
	replace daerah = "Kab. Banyuasin" 			if daerah == "Banyu Asin"
	replace daerah = "Kab. Musi Banyuasin" 		if daerah == "Musi Banyuasin"
	replace daerah = "Kab. Kotabaru" 			if daerah == "Kota Baru"
	replace daerah = "Kab. Nagakeo" 			if daerah == "Nagekeo"
	replace daerah = "Kab. Tulang Bawang" 		if daerah == "Tulangbawang"
	replace daerah = "Kab. Banyumas" 			if daerah == "Banyumas"
	replace daerah = "Kab. Nduga" 				if daerah == "Nduga *"
	replace daerah = "Kab. Karang Asem"			if daerah == "Karangasem"
	replace daerah = "Kab. Kepulauan Morotai" 	if daerah == "Pulau Morotai"
	replace daerah = "Kab. Mahakam Ulu"			if daerah == "Mahakam Ulu"
	replace daerah = "Kab. Mempawah"			if daerah == "Pontianak"
	replace daerah = "Kab. Pangkajene Kepulauan" if daerah == "Pangkajene dan Kepulauan"
	replace daerah = "Kota Makassar"			if daerah == "Kab. Makasar"
	replace daerah = "Kab. Pasangkayu"			if daerah == "Mamuju Utara"
	
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

merge 1:m nama_kabkot using  "$inpath/KorWil_matched_cleaned.dta", nogen
merge m:1 daerah using "`tmp1'", nogen keep(matched)


*keep only relevant vars 
keep nama_kabkot nama_prov median_nilai-gap_mean poverty_rate-indeks_kedalaman_miskin


*	change numeric variables as numeric
destring poverty_rate-indeks_kedalaman_miskin, replace

*save dataset
save "$outpath/cleaned-jaga-districtlevel-foranalysis", replace
