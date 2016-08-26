import sys
import warnings
import re

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

def transform_program(prog_file, cfprior_file):
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

	# var expressions = {
	# 	"bacon": bacon,
	# 	"smokeAlarm": smokeAlarm,
	# 	"neighborsAngry": neighborsAngry
	# };
	# return {
	# 	expressionValues: expressions,
	# 	output: {
	# 		bacon: bacon,
	# 		smokeAlarm: smokeAlarm,
	# 		neighborsAngry: neighborsAngry
	# 	}
	# };

	warnings.warn("expressions not implemented", Warning)

	return exogenized_prog

def write_cfpriors(prog_file, cfprior_file):
	# last line of file is just for returnify
	cfpriors = "".join(open(cfprior_file).readlines()[:-1])

	# for each sample from an ERP in program,
	# replace it with a stickySample
	sampled_values = re.findall(r"var ([a-zA-Z0-9]+) ?= ?flip\(.*\)", open(prog_file).read())
	cfprior_end = """var sampleParamsPrior = function() {
	return {
	""" + "\t" + ",\n\t\t".join(map(lambda variable: variable + ": uniform(0,1)", sampled_values)) + """
	};""" + "\n};" + "\n\n" + """var cfPrior = function() {
	return {
		input: inputPrior(),
		structureParams: structureParamsPrior(),
		sampleParams: sampleParamsPrior()
	};""" + "\n};\n"
	warnings.warn("ERP samples other than flip not implemented", Warning)
	return cfpriors + cfprior_end

print write_cfpriors(prog_file, cfprior_file)
print transform_program(prog_file, cfprior_file)

warnings.warn("observations not implemented", Warning)





# flip(bacon ? 0.9 : 0);
# 	var smokeAlarmERP = Bernoulli({
# 		p: bacon ? 0.9 : 0
# 	});
# 	var smokeAlarm = stickySample({
# 		erp: smokeAlarmERP,
# 		erpLabel: "smokeAlarm",
# 		currentLatents: currentLatents,
# 		origLatents: origLatents
# 	});