(define-module (php packages php-ext)
  #:use-module (guix download)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages pcre)
  #:use-module (guix build-system gnu)
  #:use-module (guix build gnu-build-system)
  #:use-module (php packages php))

(define-public php-ext-fileinfo
  (package
   (name "php-ext-fileinfo")
   (version (package-version php))
   (home-page "https://secure.php.net/")
   (source (origin
              (method url-fetch)
              (uri (string-append home-page "/distributions/php-" version ".tar.xz"))
              (sha256
               (base32
                "02pakyc6msnp6d00qcc2i8ppi6rnhy7dj9ga4cr05lqg7dxh20d5"))))
   (build-system gnu-build-system)
   (arguments
    `(#:configure-flags
      (list (string-append "--with-php-config="
                           (assoc-ref %build-inputs "php") "/bin/php-config"))
      #:tests? #f
      #:phases
      (modify-phases
       %standard-phases
       (add-after 'unpack 'chdir-ext
                  (lambda _
                    (chdir "ext/fileinfo")
                    #t))
       (add-before 'configure 'phpize
                   (lambda* (#:key inputs #:allow-other-keys)
                     (system (string-append "PHP_AUTOCONF=" (assoc-ref inputs "autoconf") "/bin/autoconf " (assoc-ref inputs "php") "/bin/phpize"))
                     #t))
       (replace 'install 
                (lambda* (#:key outputs #:allow-other-keys)
                  (let ((lib (string-append (assoc-ref outputs "out") "/lib")))
                    (install-file "modules/fileinfo.so" (string-append lib "/php-" ,(version-major+minor version) "/extensions"))
                    #t))))))
   (inputs
    `(("php" ,php)
      ("pcre" ,pcre2))) ;; needed by extension
   (native-inputs
    `(("autoconf" ,autoconf)))
   (synopsis "PHP fileinfo shared extension")
   (description "PHP fileinfo shared extension")
   (license (package-license php))))
