# SPDX-License-Identifier: GPL-3.0

# This is a copy of the OrgPack1 Markup Pack for Emacs Org Mode, with some indications to guide you in creating your own

Function MyMarkupPack
{   
    # MANDATORY
    [CmdletBinding()]
    param (
        # OneUp configuration object
        [Parameter(Mandatory)]
        [object]
        $config
    ,
        # Converted page configuration object
        [Parameter(Mandatory)]
        [object]
        $pageCfg
    )

    # ====================================================
    #
    #           CUSTOMIZE FROM HERE ONWARDS
    #
    # ====================================================

    # Markup output formatting using search and replace queries against a string containing the entire markup content.

    $markupPack = @(
        foreach ($attachmentCfg in $pageCfg['insertedAttachments']) {
            @{
                description = 'Change inserted attachment(s) filename references'
                replacements = @(
                    @{
                        searchRegex = [regex]::Escape( $attachmentCfg['object'].preferredName )
                        replacement = "[$( $attachmentCfg['markdownFileName'] )]($( $pageCfg['mediaPathPandoc'] )/$( $attachmentCfg['markdownFileName'] ))"
                    }
                )
            }
        }
        @{
            description = 'Replace media (e.g. images, attachments) absolute paths with relative paths'
            replacements = @(
                @{
                    # E.g. 'C:/temp/notes/mynotebook/media/somepage-image1-timestamp.jpg' -> '../media/somepage-image1-timestamp.jpg'
                    searchRegex = [regex]::Escape("$( $pageCfg['mediaParentPathPandoc'] )/") # Add a trailing front slash
                    replacement = $pageCfg['levelsPrefix']
                }
            )
        }
        @{
            description = 'Add heading'
            replacements = @(
                @{
                    searchRegex = '^[^\r\n]*'
                    replacement = & {
                        $heading = "#+title:$( $pageCfg['object'].name )"
                        $creationDate = $pageCfg['lastModifiedTime']
                        $creationDay = $creationDate.DayOfWeek.ToString()
                        if ($config['headerTimestampEnabled']['value'] -eq 1) {
                            $heading += "`n#+CREATED: $( $creationDate.ToString('<yyyy-MM-dd') ) $( $creationDay.Substring(0, 3) ) $( $creationDate.ToString('HH:mm>') )"
                        }
                        $heading
                    }
                }
            )
        }
        @{
            description = 'Remove export artifacts'
            replacements = @(
                @{
                    searchRegex = "\n\n$( [char]0x00C2 )"
                    replacement = ""
                }
            )
        }
        @{
            description = 'Separate numbered and unnumbered lists'
            replacements = @(
                @{
                    searchRegex = '(?<=\n[0-9]+. .*?)(\n)(?=\n-)'
                    replacement = '\n\n'
                }
                @{
                    searchRegex = '(?<=\n- .*?)(\n)(?=\n[0-9]+.)'
                    replacement = '\n\n'
                }
            )
        }
        if ($config['keepspaces']['value'] -eq 1 ) {
            @{
                description = 'Clear double spaces from bullets and non-breaking spaces spaces from blank lines'
                replacements = @(
                    @{
                        searchRegex = [regex]::Escape([char]0x00A0)
                        replacement = ''
                    }
                    # Remove double newlines before numbered list items
                    @{
                        searchRegex = '(?<=\n- .*?)(\n)(?=\n-)'
                        replacement = ""
                    }
                    # Remove double newlines before numbered list items
                    @{
                        searchRegex = '(?<=\n[0-9]+. .*?)(\n)(?=\n[0-9]+.)'
                        replacement = ""
                    }
                    # Remove all '>' occurrences immediately following bullet lists
                    @{
                        searchRegex = '\n>[ ]*'
                        replacement = "`n"
                    }
                )
            }
        }
        if ($config['keepescape']['value'] -eq 1) {
            @{
                description = "Clear all '\' characters"
                replacements = @(
                    @{
                        searchRegex = [regex]::Escape('\')
                        replacement = ''
                    }
                )
            }
        }
        elseif ($config['keepescape']['value'] -eq 2) {
            @{
                description = "Clear all '\' characters except those preceding alphanumeric characters"
                replacements = @(
                    @{
                        searchRegex = '\\([^A-Za-z0-9])'
                        replacement = '$1'
                    }
                )
            }
        }
        & {
            if ($config['newlineCharacter']['value'] -eq 1) {
                @{
                    description = "Use LF for newlines"
                    replacements = @(
                        @{
                            searchRegex = '\r*\n'
                            replacement = "`n"
                        }
                    )
                }
            }
            else {
                @{
                    description = "Use CRLF for newlines"
                    replacements = @(
                        @{
                            searchRegex = '\r*\n'
                            replacement = "`r`n"
                        }
                    )
                }
            }
        }
    )

    $markupPack

}