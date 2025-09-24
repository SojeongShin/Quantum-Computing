##
## ## ## save_account.py
# create an instance from https://quantum.cloud.ibm.com
# run it once to run a qc on a QPU; it saves your account info locally

def save_account():
    from qiskit_ibm_runtime import QiskitRuntimeService
    QiskitRuntimeService.save_account(
        token='b0rtjz8T2JDre-P3yzNMi_EDN2rcDSh9Z5TYIScFH_3U',
        channel='ibm_cloud',
        instance='SJ_Open_Free', # instance name
        name='sojeong.shin@stonybrook.edu', # account-name (IBMId)
        overwrite=True, # Only needed if you already have Cloud credentials.
        set_as_default=True
    )
    exit(0)

save_account()


