task king{
    File bed_in
    File bim_in
    File fam_in
    String input_prefix = basename(sub(bed_in, "\\.gz$", ""), ".bed")
    String output_basename

    # Close relative inferences
    Boolean? related
    Boolean? duplicate

    # Pairwise related inference
    Boolean? kinship
    Boolean? ibdseg
    Boolean? ibs
    Boolean? homog

    # Relatedness inference parameter
    Int? degree

    # Relationship application
    Boolean? unrelated
    Boolean? cluster
    Boolean? build

    # QC report
    Boolean? by_sample
    Boolean? by_snp
    Boolean? roh
    Boolean? autoQC

    # QC Parameter
    Float? callrate_n
    Float? callrate_m

    # Population structure
    Boolean? pca
    Boolean? mds

    # Structure parameter
    Int? projection
    Int? pcs

    # Disease association
    Boolean? tdt

    # Quantitative trait association
    Boolean? mtscore

    # Association model and parameters
    Array[String]? trait
    Array[String]? covariates
    Boolean? invnorm
    Boolean? maxP
    String trait_prefix = if(defined(trait)) then "--trait" else ""
    String covar_prefix = if(defined(covariates)) then "--covariate" else ""

    # Genetic risk score
    Boolean? risk
    Boolean? prevalence
    Boolean? noflip
    String? model

    # Optoinal string to specify chrX label
    String? sexchr

    # Runtime environment
    String docker = "rtibiocloud/king:v2.24-f0eeb5c"
    Int cpu = 1
    Int mem_gb = 2

    command {
        mkdir plink_input

        # Bed file preprocessing
        if [[ ${bed_in} =~ \.gz$ ]]; then
            # Append gz tag to let plink know its gzipped input
            gunzip -c ${bed_in} > plink_input/${input_prefix}.bed
        else
            # Otherwise just create softlink with normal
            ln -s ${bed_in} plink_input/${input_prefix}.bed
        fi

        # Bim file preprocessing
        if [[ ${bim_in} =~ \.gz$ ]]; then
            gunzip -c ${bim_in} > plink_input/${input_prefix}.bim
        else
            ln -s ${bim_in} plink_input/${input_prefix}.bim
        fi

        # Fam file preprocessing
        if [[ ${fam_in} =~ \.gz$ ]]; then
            gunzip -c ${fam_in} > plink_input/${input_prefix}.fam
        else
            ln -s ${fam_in} plink_input/${input_prefix}.fam
        fi

        # Run KING
        king -b plink_input/${input_prefix}.bed \
            --bim plink_input/${input_prefix}.bim \
            --fam plink_input/${input_prefix}.fam \
            --prefix ${output_basename} \
            ${true='--related' false="" related} \
            ${true='--duplicate' false="" duplicate} \
            ${true='--kinship' false="" kinship} \
            ${true='--ibdseg' false="" ibdseg} \
            ${true='--ids' false="" ibs} \
            ${true='--homog' false="" homog} \
            ${'--degree ' + degree} \
            ${true='--unrelated' false="" unrelated} \
            ${true='--cluster' false="" cluster} \
            ${true='--build' false="" build} \
            ${true='--bysample' false="" by_sample} \
            ${true='--bySNP' false="" by_snp} \
            ${true='--roh' false="" roh} \
            ${true='--autoQC' false="" autoQC} \
            --cpus ${cpu} \
            ${'--callrateN ' + callrate_n} \
            ${'--callrateM ' + callrate_m} \
            ${true='--pca' false="" pca} \
            ${true='--mds' false="" mds} \
            ${'--projection ' + projection} \
            ${'--pcs ' + pcs} \
            ${true='--tdt' false="" tdt} \
            ${true='--mtscore' false="" mtscore} \
            ${trait_prefix} ${sep="," trait} \
            ${covar_prefix} ${sep="," covariates} \
            ${true='--invnorm' false="" invnorm} \
            ${true='--maxP' false="" maxP} \
            ${true='--risk' false="" risk} \
            ${true='--prevalance' false="" prevalence} \
            ${true='--noflip' false="" noflip} \
            ${'--sexchr ' + sexchr} \
            ${'--model ' + model}
    }

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
    }

    output {
        File unrelated_samples = "${output_basename}unrelated.txt"
        File related_samples = "${output_basename}unrelated_toberemoved.txt"
    }
}

task unrelated{
    File bed_in
    File bim_in
    File fam_in
    String input_prefix = basename(sub(bed_in, "\\.gz$", ""), ".bed")
    String output_basename

    # Relatedness inference parameter
    Int? degree

    # Optoinal string to specify chrX label
    String? sexchr

    # Runtime environment
    String docker = "rtibiocloud/king:v2.24-f0eeb5c"
    Int cpu = 1
    Int mem_gb = 2

    command {
        mkdir plink_input

        # Bed file preprocessing
        if [[ ${bed_in} =~ \.gz$ ]]; then
            # Append gz tag to let plink know its gzipped input
            gunzip -c ${bed_in} > plink_input/${input_prefix}.bed
        else
            # Otherwise just create softlink with normal
            ln -s ${bed_in} plink_input/${input_prefix}.bed
        fi

        # Bim file preprocessing
        if [[ ${bim_in} =~ \.gz$ ]]; then
            gunzip -c ${bim_in} > plink_input/${input_prefix}.bim
        else
            ln -s ${bim_in} plink_input/${input_prefix}.bim
        fi

        # Fam file preprocessing
        if [[ ${fam_in} =~ \.gz$ ]]; then
            gunzip -c ${fam_in} > plink_input/${input_prefix}.fam
        else
            ln -s ${fam_in} plink_input/${input_prefix}.fam
        fi

        # Run KING
        king -b plink_input/${input_prefix}.bed \
            --bim plink_input/${input_prefix}.bim \
            --fam plink_input/${input_prefix}.fam \
            --prefix ${output_basename} \
            --unrelated \
            --cpus ${cpu} \
            ${'--degree ' + degree} \
            ${'--sexchr ' + sexchr}
    }

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
    }

    output {
        File unrelated_samples = "${output_basename}unrelated.txt"
        File related_samples = "${output_basename}unrelated_toberemoved.txt"
    }
}

task duplicate{
    File bed_in
    File bim_in
    File fam_in
    String input_prefix = basename(sub(bed_in, "\\.gz$", ""), ".bed")
    String output_basename

    # Optoinal string to specify chrX label
    String? sexchr

    # Runtime environment
    String docker = "rtibiocloud/king:v2.24-f0eeb5c"
    Int cpu = 1
    Int mem_gb = 2

    command {
        mkdir plink_input

        # Bed file preprocessing
        if [[ ${bed_in} =~ \.gz$ ]]; then
            # Append gz tag to let plink know its gzipped input
            gunzip -c ${bed_in} > plink_input/${input_prefix}.bed
        else
            # Otherwise just create softlink with normal
            ln -s ${bed_in} plink_input/${input_prefix}.bed
        fi

        # Bim file preprocessing
        if [[ ${bim_in} =~ \.gz$ ]]; then
            gunzip -c ${bim_in} > plink_input/${input_prefix}.bim
        else
            ln -s ${bim_in} plink_input/${input_prefix}.bim
        fi

        # Fam file preprocessing
        if [[ ${fam_in} =~ \.gz$ ]]; then
            gunzip -c ${fam_in} > plink_input/${input_prefix}.fam
        else
            ln -s ${fam_in} plink_input/${input_prefix}.fam
        fi

        # Run KING
        king -b plink_input/${input_prefix}.bed \
            --bim plink_input/${input_prefix}.bim \
            --fam plink_input/${input_prefix}.fam \
            --prefix ${output_basename} \
            --duplicate \
            --cpus ${cpu} \
            ${'--sexchr ' + sexchr}

        touch ${output_basename}.con
    }

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
    }

    output {
        File duplicate_samples = "${output_basename}.con"
    }
}


task king_samples_to_ids{
    File king_samples_in
    String output_filename

    # Runtime environment
    String docker = "ubuntu:18.04"
    Int cpu = 1
    Int mem_gb = 1

    command <<<
        perl -lane 'if($F[0] =~ KING){print join("\t", split(/->/, $F[1]))}
                    else{print;}' ${king_samples_in} > ${output_filename}
    >>>

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
    }

    output {
        File king_samples_out = "${output_filename}"
    }
}