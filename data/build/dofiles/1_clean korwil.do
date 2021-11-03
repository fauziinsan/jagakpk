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
	if (inlist("${suser}","J-PAL SEA")) {
			gl github "C:\Users\J-PAL SEA\Documents\GitHub\jagakpk\data"
			
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
// ^^ Dengan mengecek jumlah observasi for each province (by provinsi_name: gen n=_N), aku menemukan bahwa hanya DKI JKT yg ada provinsi tp gk ada kabkot
drop if strpos(nama_kabkot, "Provinsi") > 0

//Task 2 - Merge the data with the crosswalk dataset to get the BPS code
merge m:1 nama_kabkot using "$raw/district-crosswalk.dta", nogen keep(matched)
unique nama_kabkot //total kabupaten = 506. ??? kalo info dari kak hap harusnya ada 508
* note for oji, minta tolong cek lagi ji, takutnya ada kabupaten yang ngga sengaja ke drop?
* ^^ jumlah kabkot: crosswalk = 514, Korwil = 506,  jendela pencegahan = 508. 

//Task 3 - Change the unit of analysis to district and keep only relevant variables
* Checking the relevant variables
ds provinsi_name nama_kabkot dana_desa area_intervensi indikator sub_indikator tgl_lapor tgl_verif rk kode_prov nama_prov kode_kabkot, not
foreach i in `r(varlist)' {
	destring `i', replace
	}
gen cek_nilaisubindikator=bobot_subindikator*nilai_verifikasi/100 //The result is in pct
gen cek_nilaiindikator=(bobot_indikator/100)*(cek_nilaisubindikator) //The result is in pct
gen cek_areaintervensi=(bobot_area_intervensi/100)*(cek_nilaiindikator) //The result is in pct

drop cek_*

*gen var for govt checked area_intervensi 
gen govt_nilaisubindikator=bobot_subindikator*nilai/100 //The result is in pct
gen govt_nilaiindikator=(bobot_indikator/100)*(govt_nilaisubindikator) //The result is in pct
gen govt_areaintervensi=(bobot_area_intervensi/100)*(govt_nilaiindikator) //The result is in pct

* median of all relevant variables
sort nama_kabkot
foreach i in nilai_subindikator nilai_indikator nilai_area nilai nilai_verifikasi govt_nilaisubindikator govt_nilaiindikator govt_areaintervensi {
	by nama_kabkot: egen median_`i'=median(`i')
	}
	
* mean of all relevant variables
sort nama_kabkot
foreach i in nilai_subindikator nilai_indikator nilai_area nilai nilai_verifikasi govt_nilaisubindikator govt_nilaiindikator govt_areaintervensi {
	by nama_kabkot: egen mean_`i'=mean(`i')
	}
	
* summation of nilai area intervensi
foreach i in nilai_area govt_areaintervensi {
	by nama_kabkot: egen sum_`i'=sum(`i')
	}

duplicates drop nama_kabkot, force
drop dana_desa  bobot_area_intervensi indikator bobot_indikator ///
	sub_indikator bobot_subindikator nilai nilai_verifikasi tgl_lapor tgl_verif rk nilai_subindikator nilai_indikator ///
	nilai_area govt_nilaisubindikator govt_nilaiindikator govt_areaintervensi

* gen dummy target var
gen gap_median=1 if median_nilai > median_nilai_verifikasi
replace gap_median=0 if gap_median==.
gen gap_mean=1 if mean_nilai > mean_nilai_verifikasi
replace gap_mean=0 if gap_mean==.

keep nama_kabkot-kode_kabkot median_nilai median_nilai_verifikasi area_intervensi gap_median gap_mean mean_nilai mean_nilai_verifikasi
