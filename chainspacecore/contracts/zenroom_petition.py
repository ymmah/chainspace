"""
    A petition that has encrypted YES|NO signatures but that does not do:

    1) Checking the validity of the petition signatories (are they allowed to sign)
    2) Maintining privacy (the public key of the signatory is used to prevent double signing)

    This petition is an intermediate step towards a full coconut based private petition

"""

####################################################################
# imports
####################################################################
# general
from hashlib import sha256
from json    import dumps, loads, dump
from os.path import join

import subprocess

# chainspace
from chainspacecontract import ChainspaceContract

## contract name
contract = ChainspaceContract('zenroom_petition')

#ZENROOM_PATH = "/Users/raulvv/DECODE/zenroom/src/zenroom.command"
#SCRIPT_PATH = "/Users/raulvv/DECODE/zenroom/examples/elgamal"

ZENROOM_PATH = "zenroom"
SCRIPT_PATH = "/home/kozko/tmp/zenroom/examples/elgamal"


def execute_zenroom(script_filename, data_filename = None, key_filename = None):
    commands = [ZENROOM_PATH]
    if data_filename:
        commands = commands + ['-a', data_filename]

    if key_filename:
        commands = commands + ['-k', key_filename]

    commands.append(join(SCRIPT_PATH, script_filename))
    return subprocess.check_output(commands)


def write_data(data, filename="/tmp/data.json"):
    with open(filename, 'w') as outfile:
        dump(data, outfile)

####################################################################
# methods
####################################################################
# ------------------------------------------------------------------
# init
# ------------------------------------------------------------------
@contract.method('init')
def init():
    # return
    return {
        'outputs': (dumps({'type' : 'PetitionEncToken'}),)
    }

# ------------------------------------------------------------------
# create petition event
# NOTE:
#   - only 'inputs', 'reference_inputs' and 'parameters' are used to the framework
#   - if there are more than 3 param, the checker has to be implemented by hand
# ------------------------------------------------------------------
@contract.method('create_petition')
def create_petition(inputs, reference_inputs, parameters, options, private_filepath):

    output = loads(execute_zenroom('init.lua', None, private_filepath))

    # new petition object
    new_petition = {
        'type'          : 'PetitionEncObject',
        'options'       : output["options"],
        'scores'        : output["scores"],
        'public'        : output["public"],
        'proves'        : output["proves"]
    }

    # return
    return {
        'outputs': (inputs[0], dumps(new_petition))
    }

# ------------------------------------------------------------------
# add signature
# NOTE:
#   - only 'inputs', 'reference_inputs' and 'parameters' are used to the framework
#   - if there are more than 3 param, the checker has to be implemented by hand
# ------------------------------------------------------------------
@contract.method('add_signature')
def add_signature(inputs, reference_inputs, parameters, added_signature):

    last_signature = loads(inputs[0])

    ## TODO: use the added_signatures, to vote on the correct option
    output = loads(execute_zenroom("vote.lua", "/tmp/data.json"))

    new_signature = {
        "public"   : output["public"],
        "options"  : output["options"],
        "scores"   : output["scores"],
        'type'     : 'PetitionEncObject',
    }

    enc_added_signatures = output['increment']
    proof_bin = output['provebin']
    proof_sum = output['prove_sum_one']

    return {
        'outputs': (dumps(new_signature),),
        'extra_parameters' : (
            dumps(enc_added_signatures),
            dumps(proof_bin),
            dumps(proof_sum)
        )
    }

# ------------------------------------------------------------------
# tally
# NOTE:
#   - only 'inputs', 'reference_inputs' and 'parameters' are used to the framework
#   - if there are more than 3 param, the checker has to be implemented by hand
# ------------------------------------------------------------------
@contract.method('tally')
def tally(inputs, reference_inputs, parameters, key_filename):

    # retrieve last petition
    petition = loads(inputs[0])

    write_data(petition)

    output = loads(execute_zenroom('tally.lua', '/tmp/data.json', key_filename))

    outcome = output['outcome']
    proof = output['proof']
    scores = petition['scores']
    public = petition['public']

    # pack result
    result = {
        'type'      : 'PetitionEncResult',
        'outcome'   : outcome
    }

    # return
    return {
        'outputs': (dumps(result),),
        'extra_parameters' : (dumps({
            'proof': proof,
            'scores': scores,
            'public': public
        }),)
    }
#
# # ------------------------------------------------------------------
# # read
# # ------------------------------------------------------------------
# @contract.method('read')
# def read(inputs, reference_inputs, parameters):
#
#     # return
#     return {
#         'returns' : (reference_inputs[0],),
#     }
#
#
#
# ####################################################################
# # checkers
# ####################################################################
# # ------------------------------------------------------------------
# # check petitions's creation
# # ------------------------------------------------------------------
@contract.checker('create_petition')
def create_petition_checker(inputs, reference_inputs, parameters, outputs, returns, dependencies):
    try:
        # retrieve petition
        petition  = loads(outputs[1])

        write_data(petition)

        output = loads(execute_zenroom('verify_init.lua', '/tmp/data.json'))

        return output["ok"] == True

    except (KeyError, Exception):
        return False

# ------------------------------------------------------------------
# check add signature
# ------------------------------------------------------------------
@contract.checker('add_signature')
def add_signature_checker(inputs, reference_inputs, parameters, outputs, returns, dependencies):
    try:

        print "CHECKING - parameters " + str(parameters)

        # retrieve petition
        old_signature = loads(inputs[0])
        new_signature = loads(outputs[0])
        num_options = len(old_signature['options'])

        # check format
        if len(inputs) != 1 or len(reference_inputs) != 0 or len(outputs) != 1 or len(returns) != 0:
            return False
        if num_options != len(new_signature['scores']) or num_options != len(new_signature['scores']):
            return False
        if old_signature['public'] != new_signature['public']:
            return False

        print "CHECKING - tokens"
        if new_signature['type'] != 'PetitionEncObject':
            return False


        print "CHECKING - Generate params"


        # generate params, retrieve tally's public key and the parameters
        added_signature = loads(parameters[0])
        proof_bin  = loads(parameters[1])
        proof_sum  = loads(parameters[2])

        data = new_signature
        data['prove_sum_one'] = proof_sum
        data['provebin'] = proof_bin
        data['increment'] = added_signature

        write_data(data)

        output = loads(execute_zenroom('verify_vote.lua', '/tmp/data.json'))

        # otherwise
        return output["ok"]

    except (KeyError, Exception):
        return False

# ------------------------------------------------------------------
# check tally
# ------------------------------------------------------------------
@contract.checker('tally')
def tally_checker(inputs, reference_inputs, parameters, outputs, returns, dependencies):
    try:

        # retrieve petition
        petition   = loads(inputs[0])
        result = loads(outputs[0])

        # check format
        if len(inputs) != 1 or len(reference_inputs) != 0 or len(outputs) != 1 or len(returns) != 0:
            return False
        if len(petition['options']) != len(result['outcome']):
            return False

        # check tokens
        if result['type'] != 'PetitionEncResult':
            return False

        print("HEEEEEEEEEEEEEEEEEERE!!!")

        data = loads(parameters[0])
        result['proof'] = data['proof']
        result['scores'] = data['scores']
        result['public'] = data['public']

        write_data(result)

        output = loads(execute_zenroom('verify_tally.lua', '/tmp/data.json'))

        # otherwise
        return output['ok'] == True

    except (KeyError, Exception):
        return False
#
# # ------------------------------------------------------------------
# # check read
# # ------------------------------------------------------------------
# @contract.checker('read')
# def read_checker(inputs, reference_inputs, parameters, outputs, returns, dependencies):
#     try:
#
#         # check format
#         if len(inputs) != 0 or len(reference_inputs) != 1 or len(outputs) != 0 or len(returns) != 1:
#             return False
#
#         # check values
#         if reference_inputs[0] != returns[0]:
#             return False
#
#         # otherwise
#         return True
#
#     except (KeyError, Exception):
#         return False
#

####################################################################
# main
####################################################################
if __name__ == '__main__':
    contract.run()



####################################################################
