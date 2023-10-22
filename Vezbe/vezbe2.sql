/*Prikazi radnike koji se zovu Pera ili Moma.*/
SELECT * FROM radnik 
WHERE ime = any('Pera', 'Moma');

/*Prikazi radnike koji se NE zovu Pera ili Moma.*/
SELECT * FROM radnik
WHERE ime != all('Pera', 'Moma');

/*Prikazi maticne brojeve i plate radnika uvecane za godisnju premiju. Ukoliko za nekog radnika premija ne postoji, smatrati da ona iznosi 0.*/
SELECT mbr, plt + NVL(pre, 0) 
FROM radnik;

/*Prikazati koliko ima radnika.*/
SELECT COUNT(*) FROM radnik;

/*Prikazi minimalnu i maksimalnu platu radnika.*/
SELECT MIN(plt) "Minimalna plata", MAX(plt) "Maksimalna plata"
FROM radnik;

/*Prikazi broj radnika, prosecnu mesecnu platu zaokruzenu na tri decimale i ukupnu godisnju platu svih radnika.*/
SELECT COUNT(mbr), round(AVG(plt), 3), SUM(12*plt)
FROM radnik;

/*Prikazi 10 radnika koji imaju najvecu platu, sortiranih po plati u opadajucem redosledu.*/
SELECT mbr, ime, prz, plt, ROWNUM
FROM (SELECT * FROM radnik ORDER BY plt desc)
WHERE ROWNUM <= 10;

/*----------------------------------------------------------------------------------------------------------------------------------

/*Prikazi koliko radnika radi na svakom projektu i koliko je kupno angazovanje (broj casova) na tom projektu.*/
SELECT spr, COUNT(mbr), SUM(brc) 
FROM radproj
GROUP BY spr;

/*Prikazi maticni broj radnika koji rade navise od dva projekta, pored mbr-a prikayi i broj projekata na kojima radnici rade.*/
SELECT mbr, COUNT(spr)
FROM radproj
GROUP BY mbr
HAVING COUNT(spr) > 2;

/*Prikazi u rastucen redosledu plate mbr, ime, prz i plt radnika koji imaju platu vecu od prosecne.*/
SELECT plt, mbr, ime, prz
FROM radnik
WHERE plt > (SELECT AVG(plt) FROM radnik)
ORDER BY plt;

/*Prikazi radnike koji rade na projektu sa sifrom 10 a ne rade na projektu sa sifrom 30.*/
SELECT mbr, ime, prz
FROM radnik 
WHERE mbr IN (SELECT mbr from radproj WHERE spr = 10)
AND mbr NOT IN (SELECT mbr from radproj WHERE spr = 30);

/*Prikazi ime, prezime i godiste najstarijeg radnika.*/
SELECT ime, prz, god 
FROM radnik
WHERE god = (SELECT MIN(god) FROM radnik);

/*--------------------------SPAJANJE TABELA--------------------------*/

/*Prikazi mbr, prezime, ime, platu i brc angazovanja svih radnika koji rade na projektu sa sifrom 10.*/
SELECT r.mbr, prz, ime, plt, brc
FROM radnik r, radproj rp
WHERE spr = 10 AND r.mbr = rp.mbr;

/*Prikazi mbr, ime, prezime i platu radnika koji su rukovodioci projekta.*/
SELECT DISTINCT(mbr), ime, prz, plt
FROM radnik, projekat
WHERE ruk = mbr;

/*Izlistati nazive projekata na kojima radi bar jedan radnik koji radi i na projektu sa sifrom 60.*/

SELECT nap 
FROM projekat
WHERE spr in (SELECT spr 
                FROM radproj   
                WHERE mbr IN (SELECT mbr 
                                FROM radproj 
                                WHERE spr = 60));
                                
/*Prikazi mbr, prz, ime, plt i brc angazovanja svih radnika koji rade na projektu sa sifrom 10.*/    

SELECT r.mbr, prz, ime, plt, brc
FROM radnik r, radproj rp
WHERE r.mbr = rp.mbr AND rp.spr = 10;
                                
/*Prikazi imena i prezimena rukovodilaca projekata i broj projekata kojima rukovode.*/
SELECT ime, prz, COUNT(spr)
FROM radnik, projekat
WHERE ruk = mbr
GROUP BY mbr, prz, ime; /*mora i mbr zbog potencijalno dva rukovodioca sa istim imenom i prezimenom*/

/*Prikazi imena i prezimena rukovodilaca projekata i broj projekata na kojima RADE.*/

SELECT ime, prz, COUNT(distinct rp.spr)
FROM radnik r, radproj rp, projekat p
WHERE r.mbr = p.ruk AND r.mbr = rp.mbr
GROUP BY r.mbr, ime, prz;

/*Izlistati nazive projekata na kojima se ukupno radi vise od 15 casova.*/
SELECT p.nap
FROM projekat p, radproj rp
WHERE p.spr = rp.spr
GROUP BY p.spr, p.nap
HAVING SUM(rp.brc) > 15;

/*Izlistati nazive i sifre projekata na kojima je prosecno angazovanje vece od prosecnog angazovanja na svim projektima.*/
SELECT p.nap, rp.spr
FROM projekat p, radproj rp
WHERE p.spr = rp.spr
GROUP BY rp.spr, p.nap
HAVING AVG(brc) > (SELECT AVG(brc) 
                        FROM radproj);
                        
/*Prikazi mbr, ime, prz, plt radnika koji zaradjuju vise od radnika sa maticnim brojem 40.*/
SELECT mbr, ime, prz, plt
FROM radnik
WHERE plt > (SELECT plt FROM radnik WHERE mbr = 40);

/*Prikazi mbr, ime, prz, plt radnika ciji je broj sati angazovanja na nekom projektu veci od prosecnog broja sati angazovanja na tom projektu.*/
                    
SELECT DISTINCT r.mbr, ime, prz, plt
FROM radnik r, radproj rp
WHERE r.mbr = rp.mbr
            AND 
            rp.brc > (SELECT AVG(brc)
                        FROM radproj rp_pom
                        WHERE rp_pom.spr = rp.spr);