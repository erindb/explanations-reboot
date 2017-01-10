#!/usr/bin/env python

import sys
import warnings
import re
import json
import os.path

def get_tag():
	if len(sys.argv) > 1:
		tag = sys.argv[1]
	else:
		tag = raw_input("what is the name of the example? ")
	if tag[-1] == "/":
		return tag[:-1]
	else:
		return tag

tag = get_tag()

directory = tag + "/"
cfprior_file = directory + "cfprior.wppl"
prog_file = directory + "program.wppl"
expressions_file = directory + "expressions.json"
obs_file = directory + "observations.wppl"
expanded_file = directory + "autoexpanded.wppl"

def transform_program(prog_file, cfprior_file, expressions_file):
	# for each structure VARNAME with a cfprior,
	# replace it in the program with 
	# latents.VARNAME

	orig_prog_lines = open(prog_file).read().split("\nvar input = {")[0].split("var program = function(input) {\n")[1].split("\n")
	orig_prog_lines_adjusted = map(lambda line: "\t" + line, orig_prog_lines)
	orig_prog = "\n".join(orig_prog_lines_adjusted)

	# warnings.warn("structure params priors not implemented", Warning)
	structvars = get_structvars(cfprior_file)
	prog_with_struct = orig_prog
	for structvar in structvars:
		structvar = structvar.strip()
		prog_with_struct = re.sub(r"var "+structvar+" *=.*;", "var "+structvar+" = structureParams."+structvar+";", prog_with_struct)

	prog_maker_start = """var makeProgram = function(structureParams, origERPs) {
	return function (input, sampleParams) {"""

	prog_maker = prog_maker_start + "\n" + prog_with_struct + "\n};\n"

	exogenized_prog = re.sub(r"var ([a-zA-Z0-9]+) ?= ?flip\((.*)\);?", r"""
		var \1ERP = Bernoulli({p: (\2)});
		var \1Sampler = stickySampler({
			erp: serializeDist(\1ERP),
			erpLabel: "\1",
			origERP: origERPs ? serializeDist(origERPs["\1"]) : null
		});
		var \1 = \1Sampler(sampleParams["\1"]);""", prog_maker)
	warnings.warn("ERP samples other than flip not implemented", Warning)

	sampledVars = re.findall(r"var ([a-zA-Z0-9]+) ?= ?flip\(.*\);", orig_prog);
	erps = ",\n".join(map(lambda x: x + ": " + x + "ERP", sampledVars));
	warnings.warn("ERP samples other than flip not implemented", Warning)

	expressions_json = json.loads(open(expressions_file).read())
	expressions_lst = expressions_json["expressions"]
	expressions = ",\n\t\t\t\t".join(map(lambda expr: '"' + expr + '": ' + expr, expressions_lst))

	new_prog = re.sub(r"\n\t*return ({(?:[^}]*\n?)[^}]*})\;", r"""
		return {
			ERPs: {
				""" + erps + """
			},
			expressions: {\n\t\t\t\t""" + expressions + r"""
			},
			output: \1
		};""", exogenized_prog)

	return new_prog

def get_structvars(cfprior_file):
	# last line of file is just for returnify
	cfpriors = "".join(open(cfprior_file).readlines()[:-1])
	struct_prior_strings = re.findall(r"var structureParamsPrior = (?:.*\n)*.*return.*{((?:.*\n)*)}.*(?:.*\n)*.*inputPrior", cfpriors);
	if len(struct_prior_strings) != 1:
		print "error 23891"
	else:
		struct_prior_string = struct_prior_strings[0]
		struct_variable_names = re.findall(r"\t*(.*)\:.*", struct_prior_string)
		return struct_variable_names

def write_cfpriors(prog_file, cfprior_file):
	# last line of file is just for returnify
	cfpriors = "".join(open(cfprior_file).readlines()[:-1])

	# for each sample from an ERP in program,
	# replace it with a stickySample
	sampled_values = re.findall(r"var ([a-zA-Z0-9]+) ?= ?flip\(.*\)", open(prog_file).read())
	cfprior_end = """var sampleParamsPrior = function() {
	return {
	""" + "\t" + ",\n\t\t".join(map(lambda variable: variable + ": myUniform()", sampled_values)) + """
	};""" + "\n};" + "\n"
	warnings.warn("ERP samples other than flip not implemented", Warning)
	return cfpriors + cfprior_end

def write_observations(obs_file):
	if os.path.isfile(obs_file):
		return "".join(open(obs_file).readlines()[:-1])
	else:
		return "var observations = false;"

def write_expressions(expressions_file):
	expressions_json = json.loads(open(expressions_file).read())
	expressions_lst = expressions_json["expressions"]
	return "// ------------ expressions -------------------------\n\n" + \
	"var expressions = [\n\t" + ",\n\t".join(map(lambda x: "\"" + x + "\"", expressions_lst)) + "\n];"

def expand_program(prog_file, cfprior_file, expressions_file, obs_file):
	start_prog = open("transform-start.wppl").read()
	end_prog = open("transform-end.wppl").read()
	cf_comment = "// ------------ CF prior -------------------\n"
	cf_content = write_cfpriors(prog_file, cfprior_file)
	prog_comment = "// ------------ make program -------------------\n"
	prog_content = transform_program(prog_file, cfprior_file, expressions_file)
	obs_comment = "\n"
	obs_content = write_observations(obs_file)
	expressions = write_expressions(expressions_file)
	return "\n".join([
		start_prog,
		cf_comment,
		cf_content,
		prog_comment,
		prog_content,
		obs_comment,
		obs_content,
		expressions,
		end_prog
	])

open(expanded_file, "w").write(
	expand_program(prog_file, cfprior_file, expressions_file, obs_file) 
)
