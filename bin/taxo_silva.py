import sys 
from ete3 import NCBITaxa 

def usage(): 
	print("usage : python3 taxo_silva.py <silva.fasta> <outdir> <out prefix>")
	print("INPUT : silva.fasta must be silva _tax_silva_trunc files")   
	
def treat_sequences(f,out):
	f=open(f,"r") 
	o1=open(out+".notfound.id.desc","w") 
	o2=open(out+".tsv","w") 
	o2.write("#reference\tdescription\tKingdom\tPhylum\tClass\tOrder\tFamily\tGenus\Species\n") 
	for l in f: 
		if l.startswith(">"):
			l_split=l.rstrip().split(" ") 
			ref=l_split[0].lstrip(">") 
			name=l_split[1]
			name_split=name.split(";")
			if name_split[-1]=="unidentified" or "uncultured" in name_split[-1] or "metagenome" in name_split[-1] or name_split[-1]=="synthetic construct" or "bacterium" in name_split[-1]: 
				taxo=retrieve_lineage_from_taxo(name_split[:-1]) 
				if taxo=="": 
					o1.write(l) 
				else: 
					o2.write(ref+"\t"+taxo+"\n") 			
			else: 
				taxo=retrieve_lineage_from_taxo(name_split) 
				if taxo=="": 
					o1.write(l) 
				else: 
					o2.write(ref+"\t"+taxo+"\n") 			
	o1.close()
	o2.close() 		
	f.close() 	
	
def retrieve_lineage_from_taxo(taxo_tab): 
	taxo="" 
	while len(taxo_tab)!=0 and taxo=="": 
		name=taxo_tab[-1]
		try : 
			taxid=ncbi.get_name_translator([name])[name][0]
			lineage=ncbi.get_lineage(taxid)  	
			ranks=ncbi.get_rank(lineage) 
			taxo=treat_ranks(ranks)
		except : 
			taxo=""
		taxo_tab=taxo_tab[:-1]	
	return taxo 
	
def treat_ranks(ranks): 
	kingdom="-"
	phylum="-"
	species="-" 
	classe="-"
	order="-"
	family="-"
	genus="-"
	for r in ranks : 
		if ranks[r]=="superkingdom": 
			kingdom=ncbi.get_taxid_translator([r])[r] 
		elif ranks[r]=="phylum": 
			phylum=ncbi.get_taxid_translator([r])[r]	
		elif ranks[r]=="species": 
			species=ncbi.get_taxid_translator([r])[r]	
			species=species.replace("'","").replace("#","") 
		elif ranks[r]=="class": 
			classe=ncbi.get_taxid_translator([r])[r]
		elif ranks[r]=="order": 
			order=ncbi.get_taxid_translator([r])[r]
		elif ranks[r]=="family": 
			family=ncbi.get_taxid_translator([r])[r]
		elif ranks[r]=="genus":
			genus=ncbi.get_taxid_translator([r])[r]	
	taxo=kingdom+"\t"+phylum+"\t"+classe+"\t"+order+"\t"+family+"\t"+genus+"\t"+species		
	return taxo			
	
if len(sys.argv) != 4: 
	usage() 
	exit() 	

out=sys.argv[2]+"/"+sys.argv[3] 	
ncbi=NCBITaxa() 
treat_sequences(sys.argv[1],out) 
	
