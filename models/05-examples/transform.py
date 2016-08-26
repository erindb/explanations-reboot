import sys
import warnings
import re
import json

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
cfprior_file = directory + tag + "-cfprior.wppl"
prog_file = directory + tag + "-program.wppl"
expressions_file = directory + tag + "-expressions.json"
obs_file = directory + tag + "-observations.wppl"
expanded_file = directory + tag + "-autoexpanded.wppl"

def transform_program(prog_file, cfprior_file, expressions_file):
	# for each structure VARNAME with a cfprior,
	# replace it in the program with 
	# latents.VARNAME
	warnings.warn("structure params priors not implemented", Warning)

	orig_prog_lines = open(prog_file).read().split("\nvar input = {")[0].split("var program = function(input) {\n")[1].split("\n")
	orig_prog_lines_adjusted = map(lambda line: "\t" + line, orig_prog_lines)
	orig_prog = "\n".join(orig_prog_lines_adjusted)

	prog_maker_start = """var makeProgram = function(structureParams, origStructureParams) {
	return function (input, sampleParams, origInput, origSampleParams) {

		var currentLatents = {
			input: input,
			structureParams: structureParams,
			sampleParams: sampleParams
		};
		var origLatents = {
			input: origInput,
			structureParams: origStructureParams,
			sampleParams: origSampleParams
		};"""

	prog_maker = prog_maker_start + "\n" + orig_prog + "\n};\n"

	exogenized_prog = re.sub(r"var ([a-zA-Z0-9]+) ?= ?flip\((.*)\)", r"""var \1ERP = Bernoulli({p: (\2)});
		var \1 = stickySample({
			erp: \1ERP,
			erpLabel: "\1",
			currentLatents: currentLatents,
			origLatents: origLatents
		})""", prog_maker)
	warnings.warn("ERP samples other than flip not implemented", Warning)

	expressions_json = json.loads(open(expressions_file).read())
	expressions_lst = expressions_json["expressions"]
	expressions = ",\n\t\t\t\t".join(map(lambda expr: '"' + expr + '": ' + expr, expressions_lst))

	new_prog = re.sub(r"\n\t\treturn ({(?:.*\n)*\t\t})", r"""
		return {
			expressions: {\n\t\t\t\t""" + expressions + r"""
			},
			output: \1
		};""", exogenized_prog)

	return new_prog

def write_cfpriors(prog_file, cfprior_file):
	# last line of file is just for returnify
	cfpriors = "".join(open(cfprior_file).readlines()[:-1])

	# for each sample from an ERP in program,
	# replace it with a stickySample
	sampled_values = re.findall(r"var ([a-zA-Z0-9]+) ?= ?flip\(.*\)", open(prog_file).read())
	cfprior_end = """var sampleParamsPrior = function() {
	return {
	""" + "\t" + ",\n\t\t".join(map(lambda variable: variable + ": uniform(0,1)", sampled_values)) + """
	};""" + "\n};" + "\n"
	warnings.warn("ERP samples other than flip not implemented", Warning)
	return cfpriors + cfprior_end

def write_observations(obs_file):
	return "".join(open(obs_file).readlines()[:-1])

def expand_program(prog_file, cfprior_file, expressions_file, obs_file):
	start_prog = open("transform-start.wppl").read()
	end_prog = open("transform-end.wppl").read()
	cf_comment = "// ------------ CF prior -------------------\n"
	cf_content = write_cfpriors(prog_file, cfprior_file)
	prog_comment = "// ------------ make program -------------------\n"
	prog_content = transform_program(prog_file, cfprior_file, expressions_file)
	obs_comment = "\n"
	obs_content = write_observations(obs_file)
	return "\n".join([
		start_prog,
		cf_comment,
		cf_content,
		prog_comment,
		prog_content,
		obs_comment,
		obs_content,
		end_prog
	])

open(expanded_file, "w").write(
	expand_program(prog_file, cfprior_file, expressions_file, obs_file) 
)
