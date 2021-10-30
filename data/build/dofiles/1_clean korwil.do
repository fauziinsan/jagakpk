* ==============================================================================
* Jaga.id: Cleaning Dataset Korwil
* ==============================================================================


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
	if (inlist("${suser}","........")) {
			
			}	


**	Globals
gl raw "$github/build/raw"

//Task 1 - Clean the district name
*	import the data
import excel using "$raw/Korwil/KorWil.xlsx", clear firstrow

*	double column name
drop if instansi == "instansi"

*	remove prefix "pemerintah" and change "Kabupaten" to "Kab."
rename instansi nama_kabkot
replace nama_kabkot = subinstr(nama_kabkot, "Pemerintah", "",.)
replace nama_kabkot = ustrtrim(subinstr(nama_kabkot, "Kabupaten", "Kab.",.))

*	find the "correct" district name 
//	different name compared to the BPS crosswalk
replace nama_kabkot = "Kab. Batang Hari" 			if nama_kabkot == "Kab. Batanghari"
replace nama_kabkot = "Kab. Batubara"	 			if nama_kabkot == "Kab. Batu Bara"
replace nama_kabkot = "Kab. Fak-Fak"	 			if nama_kabkot == "Kab. Fak Fak"
replace nama_kabkot = "Kab. Jaya Wijaya" 			if nama_kabkot == "Kab. Jayawijaya"
replace nama_kabkot = "Kab. Karang Asem" 			if nama_kabkot == "Kab. Karangasem"
replace nama_kabkot = "Kab. Kep. Sangihe" 			if nama_kabkot == "Kab. Kepulauan Sangihe"
replace nama_kabkot = "Kab. Kepulauan Morotai"		if nama_kabkot == "Kab. Pulau Morotai"
replace nama_kabkot = "Kab. Kuburaya"				if nama_kabkot == "Kab. Kubu Raya"
replace nama_kabkot = "Kab. Labuhan Batu"			if nama_kabkot == "Kab. Labuhanbatu"
replace nama_kabkot = "Kab. Labuhan Batu Selatan"	if nama_kabkot == "Kab. Labuhanbatu Selatan"
replace nama_kabkot = "Kab. Labuhan Batu Utara"		if nama_kabkot == "Kab. Labuhanbatu Utara"
replace nama_kabkot = "Kab. Lima Puluh Koto"		if nama_kabkot == "Lima Puluh Kota"
replace nama_kabkot = "Kab. Memberamo Raya"			if nama_kabkot == "Kab. Mamberamo Raya"
replace nama_kabkot = "Kab. Membramo Tengah"		if nama_kabkot == "Kab. Mamberamo Tengah"
replace nama_kabkot = "Kab. Muko-muko"				if nama_kabkot == "Kab. Muko Muko"
replace nama_kabkot = "Kab. Nagakeo"				if nama_kabkot == "Kab. Nagekeo"
replace nama_kabkot = "Kab. Rote-Ndao"				if nama_kabkot == "Kab. Rote Ndao"
replace nama_kabkot = "Kab. Tojo Una-Una"			if nama_kabkot == "Kab. Tojo Una Una"
replace nama_kabkot = "Kab. Tolitoli"				if nama_kabkot == "Kab. Toli Toli"
replace nama_kabkot = "Kab. halmahera Utara"		if nama_kabkot == "Kab. Halmahera Utara"
replace nama_kabkot = "Kota Baubau"					if nama_kabkot == "Kota Bau Bau"
replace nama_kabkot = "Kota Pagar Alam"				if nama_kabkot == "Kota Pagaralam"
replace nama_kabkot = "Kota Palangka Raya"			if nama_kabkot == "Kota Palangkaraya"
replace nama_kabkot = "Kota Pangkalpinang"			if nama_kabkot == "Kota Pangkal Pinang"
replace nama_kabkot = "Kota Parepare"				if nama_kabkot == "Kota Pare Pare"
replace nama_kabkot = "Kota Pematangsiantar"		if nama_kabkot == "Kota Pematang Siantar"
replace nama_kabkot = "Kota Tanjungpinang"			if nama_kabkot == "Kota Tanjung Pinang"
replace nama_kabkot = "Kota Padangsidempuan"		if nama_kabkot == "Kota Padangsidimpuan"
replace nama_kabkot = "Kab. Maluku Tenggara Barat"	if nama_kabkot == "Kab. Kepulauan Tanimbar" //MTB merupakan nama lama


//	drop province level observation 
//	menariknya, ada yang data provinsinya ada, tapi gaada kabkotnya (e.g DKI jakarta, Bali, gorontalo,etc)
drop if strpos(nama_kabkot, "Provinsi") > 0

//Task 2 - Merge the data with the crosswalk dataset to get the BPS code
merge m:1 nama_kabkot using "$raw/district-crosswalk.dta", nogen keep(matched)
unique nama_kabkot //total kabupaten = 506. ??? kalo info dari kak hap harusnya ada 508
* note for oji, minta tolong cek lagi ji, takutnya ada kabupaten yang ngga sengaja ke drop?

//Task 3 - Change the unit of analysis to district and keep only relevant variables