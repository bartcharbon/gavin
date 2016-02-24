package org.molgenis.calibratecadd;

import java.util.Arrays;
import java.util.List;


public class Step9_AllValidations
{
	public static void main(String[] args) throws Exception
	{
		String geneSumm = "/Users/jvelde/github/maven/molgenis-data-cadd/data/CCGG_ClassificationSource_GeneSummary.tsv";
		List<String> datasets = Arrays.asList(new String[]{"ClinVarNew", "MutationTaster2", "UMCG_Onco", "UMCG_Various", "VariBenchTest", "VariBenchTraining"});
		List<String> tools = Arrays.asList(new String[]{"OurTool", "PONP2", "CADD", "PROVEAN", "SIFT", "PolyPhen2", "MSC", "Condel"});
		
		for(String dataset: datasets)
		{
			for(String tool: tools)
			{
				new Step9_Validation(geneSumm, "/Users/jvelde/Desktop/clinvarcadd/datasets_inoneplace/" + dataset, tool);
			}
		}
		
		
	}
	
}