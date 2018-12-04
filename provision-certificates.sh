#!/bin/bash
set -eux

ca_file_name='example-ca'
ca_common_name='Example CA'

mkdir -p /vagrant/shared/$ca_file_name
pushd /vagrant/shared/$ca_file_name

# create the CA certificate.
if [ ! -f $ca_file_name-crt.pem ]; then
    openssl genrsa \
        -out $ca_file_name-key.pem \
        2048 \
        2>/dev/null
    chmod 400 $ca_file_name-key.pem
    openssl req -new \
        -sha256 \
        -subj "/CN=$ca_common_name" \
        -key $ca_file_name-key.pem \
        -out $ca_file_name-csr.pem
    openssl x509 -req -sha256 \
        -signkey $ca_file_name-key.pem \
        -extensions a \
        -extfile <(echo "[a]
            basicConstraints=critical,CA:TRUE,pathlen:0
            keyUsage=critical,digitalSignature,keyCertSign,cRLSign
            ") \
        -days 365 \
        -in  $ca_file_name-csr.pem \
        -out $ca_file_name-crt.pem
    openssl x509 \
        -in $ca_file_name-crt.pem \
        -outform der \
        -out $ca_file_name-crt.der
    # dump the certificate contents (for logging purposes).
    #openssl x509 -noout -text -in $ca_file_name-crt.pem
fi

# create the client certificates to authenticate into the vpn.
vpn_client_common_names=(
    'moon.vpn.example.com'
    'sun.vpn.example.com'
)
for common_name in "${vpn_client_common_names[@]}"; do
    if [ ! -f $common_name-crt.pem ]; then
        openssl genrsa \
            -out $common_name-key.pem \
            2048 \
            2>/dev/null
        chmod 400 $common_name-key.pem
        openssl req -new \
            -sha256 \
            -subj "/CN=$common_name" \
            -key $common_name-key.pem \
            -out $common_name-csr.pem
        openssl x509 -req -sha256 \
            -CA $ca_file_name-crt.pem \
            -CAkey $ca_file_name-key.pem \
            -CAcreateserial \
            -extensions a \
            -extfile <(echo "[a]
                extendedKeyUsage=critical,clientAuth,serverAuth
                ") \
            -days 365 \
            -in  $common_name-csr.pem \
            -out $common_name-crt.pem
        openssl pkcs12 -export \
            -keyex \
            -inkey $common_name-key.pem \
            -in $common_name-crt.pem \
            -certfile $common_name-crt.pem \
            -passout pass: \
            -out $common_name-key.p12
        # dump the certificate contents (for logging purposes).
        #openssl x509 -noout -text -in $common_name-crt.pem
        #openssl pkcs12 -info -nodes -passin pass: -in $common_name-key.p12
    fi
done
