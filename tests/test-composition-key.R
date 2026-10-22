source('scripts/composition_key.R')
stopifnot(identical(composition_key('Bi S3 Cu Pb'), composition_key('Pb Cu Bi S3')),
          identical(composition_key('Ag2 S'), composition_key('Ag4 S2')),
          identical(composition_key('Sn Ag2 (Mn.69 Zn.31) S4'), composition_key('Ag2Mn0.69Zn0.31SnS4')),
          identical(composition_key('Ca3(PO4)2'),composition_key('Ca3P2O8')),
          is.na(composition_key('Ca(PO4')), is.na(composition_key('CaPO4)')),
          is.na(composition_key('Fe2+')),is.na(composition_key(NA_character_)))
cat('Composition ordering, stoichiometric scaling, grouped occupancies and invalid formulas: passed\n')
