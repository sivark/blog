;;; publish.el --- Generate a simple static HTML blog
;;; Code:

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(dolist (pkg '(templatel htmlize weblorg))
  (unless (package-installed-p pkg)
    (package-refresh-contents)
    (package-install pkg)))

(require 'weblorg)
(require 'htmlize)

(setq org-html-htmlize-output-type 'css)
(setq org-export-with-smart-quotes t)
(setq org-export-with-special-strings nil)

(defun my-smart-quotes (str)
  "Convert straight quotes in STR to typographic curly quotes without altering dashes."
  (if (stringp str)
      (let ((res str))
        ;; Double quotes
        (setq res (replace-regexp-in-string "\"\\([^\"]*\\)\"" "“\\1”" res))
        (setq res (replace-regexp-in-string "\\(^\\|[ \t(]\\)\"" "\\1“" res))
        (setq res (replace-regexp-in-string "\"" "”" res))
        ;; Contractions & single quotes
        (setq res (replace-regexp-in-string "\\([[:alnum:]]\\)'\\([[:alnum:]]\\)" "\\1’\\2" res))
        (setq res (replace-regexp-in-string "'\\([^']*\\)'" "‘\\1’" res))
        res)
    str))

(advice-add 'weblorg--parse-org-keyword :filter-return
            (lambda (cell)
              (when (and (consp cell)
                         (member (car cell) '("title" "description")))
                (setcdr cell (my-smart-quotes (cdr cell))))
              cell))

;; Define the site
(setq my-site
      (weblorg-site
       :base-url "http://sivark.me/blog"
       :template-vars '(("author" . "Sivaramakrishnan Swaminathan")
                        ("description" . "Spilled on to the web, my ponderings have.")
                        ("base_url" . "."))))

;; Generate blog posts
(weblorg-route
 :site my-site
 :name "posts"
 :input-pattern "src/posts/*.org"
 :template "post.html"
 :output "{{ slug }}.html"
 :url "{{ slug }}.html")

;; Generate posts summary (index)
(weblorg-route
 :site my-site
 :name "index"
 :input-pattern "src/posts/*.org"
 :input-aggregate #'weblorg-input-aggregate-all-desc
 :template "blog.html"
 :output "index.html"
 :url "index.html"
 :template-vars '(("title" . "Posts")))

;; Generate RSS feed
(weblorg-route
 :site my-site
 :name "feed"
 :input-pattern "src/posts/*.org"
 :input-aggregate #'weblorg-input-aggregate-all-desc
 :template "feed.xml"
 :output "feed.xml"
 :url "feed.xml")

;; Copy static assets
(weblorg-copy-static
 :site my-site
 :output "static/{{ file }}"
 :url "static/{{ file }}")

;; Export everything
(weblorg-export)
;;; publish.el ends here
