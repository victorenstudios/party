var Config = new Object();
Config.closeKeys = [27];
function SendMessage(namespace, data) {
    $.post('https://XNS-Party/' + namespace, JSON.stringify(data));
}

let itembuy = null

$(function() {
    closemenu = function() {
        $('.main-bg').fadeOut();

        $('.event-bg').fadeOut();
        $('.exit-event-bg').fadeOut();
        $('.warzone-bg').fadeOut();
        $('.airdrop-bg').fadeOut();
        $('.flag-bg').fadeOut();

        $('.shop-bg').fadeOut();
        $(".InputItemCount").fadeOut();
        document.getElementById('InputItemCount').value = ''
        itembuy = null

        $('.squad-bg').fadeOut();
        $('.mamage-squad-bg').fadeOut();
        $('.CreateSquadInput').fadeOut();
        document.getElementById('myInput2').value = ''
        document.getElementById('SquadName').value = ''
        $(".QuitSquad").fadeOut();

        $('.family-bg').fadeOut();
        $(".seemember-bg").fadeOut();
        $(".ManageFamilyBG").fadeOut();
        $(".CreateFamily").fadeOut();
        $("#familylist").empty();
        $("#familydetail").empty();
        $(".ManageRequestBG").fadeOut();
        $(".QuitFamily").fadeOut();
        $(".DeleteFamily").fadeOut();
        $(".UpGrageSlot").fadeOut();
        $(".UpRank").fadeOut();
        document.getElementById('myInput').value = ''

        SendMessage("cancel", {});
    }

    $(document).ready(function() {
        $("body").on("keyup", function(key) {
            if (Config.closeKeys.includes(key.which)) {
                closemenu();
            }
        });
    });

    window.addEventListener('message', function(event) {
        if (event.data.action == 'openmenu') {
            PlaySounds("open")
            $('.main-bg').fadeIn();
        } else if (event.data.action == 'closemenu') {
            closemenu();
        } else if (event.data.action == 'eventalert') {
            $('.alert-bg').fadeIn();
            PlaySounds(event.data.Sound)
            $('#eventtext').html(event.data.Text);
            setTimeout(() => {
                $('.alert-bg').fadeOut();
            }, 5000);
        } else if (event.data.action == 'FlagAlert') {
            $('.eventalert-bg2').fadeIn();
            $('.eventalert-text3').html(event.data.PlayerText);
            $('#flagtime').html(event.data.Text);
        } else if (event.data.action == 'CloseFlag') {
            $('.eventalert-bg2').fadeOut();
        } else if (event.data.action == 'AirdropAlert') {
            $('.eventalert-bg').fadeIn();
            $('#airdroptime').html(event.data.Text);
        } else if (event.data.action == 'CloseAirdropAlert') {
            $('.eventalert-bg').fadeOut();
        } else if (event.data.action == 'SetAvatar') {
            var sek = new XMLHttpRequest();
            sek.responseType = "text";
            sek.open('GET', event.data.Url, true);
            sek.send();
            sek.onreadystatechange = processRequest;

            function processRequest(e) {
                if (sek.readyState == 4 && sek.status == 200) {
                    var string = sek.responseText.toString();
                    var array = string.split("avatarfull");
                    var array2 = array[1].toString().split('"');
                    $('.Profile').html(
                        `
                            <img src="${array2[2].toString()}">
                            <div class="discord-name">
                                <div class="discord-text">${event.data.Name}</div>
                            </div>
                            <div class="steam-hex">
                                <div class="steam-text">${event.data.Hex}</div>
                            </div>
                        `
                    );
                }
            }
        } else if (event.data.action == 'GetFamily') {
            if (event.data.MyFamily.Name == null) {
                $('.managefamilybottom').html(`
                    <div class="managefamily" onclick="CreateFamilyMenu()">
                        Create Family
                    </div>
                `);
            } else {
                $('.managefamilybottom').html(`
                    <div class="managefamily" onclick="ManageFamily()">
                        Manage Family
                    </div>
                `);
            }
            $.each(event.data.DataFamily, function(index, data) {
                var apps = `
                <div class="gang-box-bg" onclick="Seeinfo('${data.Name}')">
                    <div class="name-box">
                        <span>${data.Name}</span>
                    </div>
                    <div class="member-box">
                        ${data.Member} / ${data.MaxMember}
                    </div>
                </div>
                `;
                $("#familylist").append(apps);
            });
            $('#moneycreatefamily').html(event.data.CreateCost);
        } else if (event.data.action == 'GetFamilyInfo') {
            $(".seemember-bg").fadeOut();
            if (event.data.MyFamily.Name == null) {
                var apps = `
                    <div class="gangname">
                        <img src="${event.data.Family.avatar_url}">
                        <div class="family-name">
                            <div class="name-text">${event.data.Family.name}</div>
                        </div>
                        <div class="family-exp">
                            <div class="exp-text">${event.data.Family.exp} EXP</div>
                        </div>
                    </div>
                    <div class="gangdetail">
                        <div class="boss-bg">
                            <div class="headerdetail">
                                <i style="color:#ef60a1;" class="fa-solid fa-crown"></i></i>&nbsp;LEADER:
                            </div>
                            <div class="bottomdetail">
                                ${event.data.Family.boss}
                            </div>
                        </div>
                        <div class="memeber-bg">
                            <div class="headerdetail">
                                <i style="color:#ef60a1;" class="fa-solid fa-people-group"></i>&nbsp;MEMBER COUNT :
                            </div>
                            <div class="bottomdetail">
                                ${event.data.Family.membercount}/${event.data.Family.maxmembercount}
                            </div>
                        </div>
                    </div>
                    <div class="bio">
                        <div class="bio-text">
                            ${event.data.Family.bio}
                        </div>
                    </div>
                    <div class="seememberfamily" onclick="SeeMember('${event.data.Family.name}')">
                       View Members
                    </div>
                    <div class="applyfamily" onclick="ApplyFamily('${event.data.Family.name}')">
                        Request to join Family
                    </div>
                `;
            } else {
                var apps = `
                    <div class="gangname">
                        <img src="${event.data.Family.avatar_url}">
                        <div class="family-name">
                            <div class="name-text">${event.data.Family.name}</div>
                        </div>
                        <div class="family-exp">
                            <div class="exp-text">${event.data.Family.exp} EXP</div>
                        </div>
                    </div>
                    <div class="gangdetail">
                        <div class="boss-bg">
                            <div class="headerdetail">
                                <i style="color:#ef60a1;" class="fa-solid fa-crown"></i>&nbsp;LEADER :
                            </div>
                            <div class="bottomdetail">
                                ${event.data.Family.boss}
                            </div>
                        </div>
                        <div class="memeber-bg">
                            <div class="headerdetail">
                                <i style="color:#ef60a1;" class="fa-solid fa-people-group"></i>&nbsp;MEMBER COUNT : 
                            </div>
                            <div class="bottomdetail">
                                ${event.data.Family.membercount}/${event.data.Family.maxmembercount}
                            </div>
                        </div>
                    </div>
                    <div class="bio">
                        <div class="bio-text">
                            ${event.data.Family.bio}
                        </div>
                    </div>
                    <div class="seememberfamily" onclick="SeeMember('${event.data.Family.name}')">
                        View Members
                    </div>
                `;
            }
            $("#familydetail").append(apps);
        } else if (event.data.action == 'SeeMember') {
            $(".seemember-bg").fadeIn();
            $("#memberlist").empty();
            $.each(event.data.Member, function(index, data) {
                var apps = `
                    <div class="memberlist-box">
                        <div class="ClassRank ${data.Grage}">
                            ${data.Label}
                        </div>
                        <div class="MemberName">
                            <span>${data.Name}</span>
                        </div>
                    </div>
                `
                $("#memberlist").append(apps);
            });
        } else if (event.data.action == 'GetManageFamily') {
            $("#ManageRequestId").empty();
            $("#ManageMemberBG").empty();
            $(".ManageGangName").empty();
            $(".ManageImgId").empty();
            $(".ManageBioId").empty();
            $("#SubmitManageId").empty();
            if (event.data.MyFamily.Grage == "Boss") {
                if (event.data.RequestCount == true) {
                    var apps = `
                        <div class="ManageRequestBottom" onclick="ManageRequestBottomMenu()">
                            Request to join
                            <div class="AlertRequest">
                                <i class="fa-solid fa-exclamation"></i>
                            </div>
                        </div>
                        <div class="QuitBottom" onclick="DeleteFamily()">
                            Delete Family
                        </div>
                        <div class="UpGrageBottom" onclick="UpGrageSlot()">
                            Upgrade Family
                        </div>
                    `
                } else {
                    var apps = `
                        <div class="ManageRequestBottom" onclick="ManageRequestBottomMenu()">
                            Request to join
                        </div>
                        <div class="QuitBottom" onclick="DeleteFamily()">
                            Delete Family
                        </div>
                        <div class="UpGrageBottom" onclick="UpGrageSlot()">
                            Upgrade Family
                        </div>
                    `
                }
                $("#ManageRequestId").append(apps);
            } else {
                if (event.data.MyFamily.HaveRecruit == true) {
                    var apps = `
                        <div class="ManageRequestBottom" onclick="ManageRequestBottomMenu()">
                            Request to join
                            <div class="AlertRequest">
                                <i class="fa-solid fa-exclamation"></i>
                            </div>
                        </div>
                        <div class="QuitBottom" onclick="QuitFamily()">
                            Leave Family
                        </div>
                    `
                    $("#ManageRequestId").append(apps);
                } else {
                    var apps = `
                        <div class="ManageRequestBottom" onclick="QuitFamily()">
                            Leave Family
                        </div>
                    `
                    $("#ManageRequestId").append(apps);
                }
            }
            
            if (event.data.MyFamily.HaveRecruit == true) {
                if (event.data.MyFamily.Grage == "Boss") {
                    $(".ManageGangName").append(`
                        <img src="${event.data.Family.avatar_url}">
                        <textarea class="ManageName" id="ManageName" name="ManageName" maxlength="18">${event.data.Family.name}</textarea>
                        <div class="family-exp">
                            <div class="exp-text">${event.data.Family.exp} EXP</div>
                        </div>
                    `);
                    $(".ManageImgId").append(`
                        <textarea class="ManageImg" id="ManageImg" name="ManageImg">${event.data.Family.avatar_url}</textarea>
                    `);
                    $(".ManageBioId").append(`
                        <textarea class="ManageBio" id="ManageBio" name="ManageBio" maxlength="128">${event.data.Family.bio}</textarea>
                    `);
                    $("#SubmitManageId").append(`
                        <div class="SubmitManage" onclick="SubmitManage()">
                            Change Log
                        </div>
                    `);
                } else { 
                    $(".ManageGangName").append(`
                        <img src="${event.data.Family.avatar_url}">
                        <div class="ManageName">${event.data.Family.name}</div>
                        <div class="family-exp">
                            <div class="exp-text">${event.data.Family.exp} EXP</div>
                        </div>
                    `);
                    $(".ManageImgId").append(`
                        <div class="ManageImg2">${event.data.Family.avatar_url}</div>
                    `);
                    $(".ManageBioId").append(`
                        <div class="ManageBio2">${event.data.Family.bio}</div>
                    `);
                }

                $.each(event.data.Member, function(index, data) {
                    if (event.data.Identifier == data.Identifier) {
                        var apps = `
                            <div class="MemberBG">
                                <div class="ClassRank ${data.Grage}">
                                    ${data.Label}
                                </div>
                                <div class="MemberName">
                                    ${data.Name}
                                </div>
                            </div>
                        `
                    } else {
                        var apps = `
                            <div class="MemberBG">
                                <div class="ClassRank ${data.Grage}">
                                    ${data.Label}
                                </div>
                                <div class="MemberName">
                                    ${data.Name}
                                </div>
                                <div class="KickManageBottom" onclick="Kick('${data.Identifier}')">
                                    <i class="fa-solid fa-x"></i>
                                </div>
                                <div class="RankManageBottom" onclick="UpRank('${data.Identifier}')">
                                    <i class="fa-solid fa-arrow-up"></i>
                                </div>
                            </div>
                        `
                    }
                    $("#ManageMemberBG").append(apps);
                });
            } else {
                $(".ManageGangName").append(`
                    <img src="${event.data.Family.avatar_url}">
                    <div class="ManageName">${event.data.Family.name}</div>
                    <div class="family-exp">
                        <div class="exp-text">${event.data.Family.exp} EXP</div>
                    </div>
                `);
                $(".ManageImgId").append(`
                    <div class="ManageImg2">${event.data.Family.avatar_url}</div>
                `);
                $(".ManageBioId").append(`
                    <div class="ManageBio2">${event.data.Family.bio}</div>
                `);
                $.each(event.data.Member, function(index, data) {
                    var apps = `
                        <div class="MemberBG">
                            <div class="ClassRank ${data.Grage}">
                                ${data.Label}
                            </div>
                            <div class="MemberName">
                                ${data.Name}
                            </div>
                        </div>
                    `
                    $("#ManageMemberBG").append(apps);
                });
            }
        } else if (event.data.action == 'RefreshPlayerInFamily') {
            $("#ManageMemberBG").empty();
            $.each(event.data.Member, function(index, data) {
                if (event.data.Identifier == data.Identifier) {
                    var apps = `
                        <div class="MemberBG">
                            <div class="ClassRank ${data.Grage}">
                                ${data.Label}
                            </div>
                            <div class="MemberName">
                                ${data.Name}
                            </div>
                        </div>
                    `
                } else {
                    var apps = `
                        <div class="MemberBG">
                            <div class="ClassRank ${data.Grage}">
                                ${data.Label}
                            </div>
                            <div class="MemberName">
                                ${data.Name}
                            </div>
                            <div class="KickManageBottom" onclick="Kick('${data.Identifier}')">
                                <i class="fa-solid fa-x"></i>
                            </div>
                            <div class="RankManageBottom" onclick="UpRank('${data.Identifier}')">
                                <i class="fa-solid fa-arrow-up"></i>
                            </div>
                        </div>
                    `
                }
                $("#ManageMemberBG").append(apps);
            });
        } else if (event.data.action == 'GetManageRequest') {
            $("#ManageRequestBG").empty();
            $.each(event.data.Request, function(index, data) {
                var apps = `
                    <div class="MemberBG">
                        <div class="MemberName2">
                            ${data.Name}
                        </div>
                        <div class="KickManageBottom" onclick="Deny('${data.Identifier}')">
                            <i class="fa-solid fa-x"></i>
                        </div>
                        <div class="RankManageBottom" onclick="Accept('${data.Identifier}')">
                            <i class="fa-solid fa-check"></i>
                        </div>
                    </div>
                `
                $("#ManageRequestBG").append(apps);
            });
        } else if (event.data.action == 'GetRank') {
            $("#all-rank").empty();
            $.each(event.data.Rank, function(index, data) {
                var apps = `
                    <option value="` + data.Grage + `">` + data.label + `</option>
                `
                $("#all-rank").append(apps);
            });
        } else if (event.data.action == 'GetShop') {
            $("#gccount").html(event.data.Gc);
            $("#item-shop").empty();
            $.each(event.data.Shop, function(index, data) {
                var apps = `
                    <div class="item-box-bg" onclick="BuyItem('` + data.item + `')">
                        <div class="item-box-header">
                            <img src="nui://esx_inventoryhud/html/img/items/` + data.item + `.png" width="115px" height="115px" />
                            <div class="item-box-gc">
                            ` + data.price + `&nbsp;<span>GC</span>
                            </div>
                        </div>
                        <div class="item-box-bottom">
                            ` + data.label + `</span>
                        </div>
                    </div>
                `
                $("#item-shop").append(apps);
            });
        } else if (event.data.action == 'GetAirdrop') {
            $("#Airdrop").empty();
            $.each(event.data.Airdrop, function(index, data) {
                if (event.data.StatusAirdrop == true) {
                    if (data.HaveAirdrop == true) {
                        if (data.Text == "เกมกำลังดำเนินการ") {
                            var apps = `
                                <div class="event-box-bg">
                                    <div class="event-name-text">
                                        ` + data.NameAirdrop + `
                                    </div>
                                    <div class="event-player-text">
                                        <span data-airdropname="${data.Label}">` + data.Text + `</span> ` + data.Player + ` /  ` + data.MaxPlayer + `
                                    </div>
                                </div>
                            `
                        } else {
                            var apps = `
                                <div class="event-box-bg" onclick="JoinAirdrop('` + data.Label + `')">
                                    <div class="event-name-text">
                                        ` + data.NameAirdrop + `
                                    </div>
                                    <div class="event-player-text">
                                        <span data-airdropname="${data.Label}">` + data.Text + `</span> ` + data.Player + ` /  ` + data.MaxPlayer + `
                                    </div>
                                </div>
                            `
                        }
                    } else {
                        var apps = `
                            <div class="event-box-bg">
                                <div class="event-name-text">
                                    ` + data.NameAirdrop + `
                                </div>
                                <div class="event-player-text">
                                    <span data-airdropname="${data.Label}">` + data.Text + `</span>
                                </div>
                            </div>
                        `
                    }
                } else {
                    var apps = `
                        <div class="event-box-bg">
                            <div class="event-name-text">
                                ` + data.NameAirdrop + `
                            </div>
                            <div class="event-player-text">
                                ` + data.Text + `
                            </div>
                        </div>
                    `
                }
                $("#Airdrop").append(apps);
            });
        } else if (event.data.action == 'SyncAirdropTime') {
            $.each(event.data.Airdrop, function(index, data) {
                let airdropnumber = data.Label;
                $(`[data-airdropname="${airdropnumber}"]`).text(event.data.Time)
            });
        } else if (event.data.action == 'AlertTime') {
            $('.alerttime-bg').fadeIn();
            $("#alerttime").html(event.data.Time);
        } else if (event.data.action == 'CloseAlertTime') {
            $('.alerttime-bg').fadeOut();
        } else if (event.data.action == 'GetFlag') {
            $("#Flag").empty();
            $.each(event.data.Flag, function(index, data) {
                if (event.data.StatusFlag == true) {
                    if (data.HaveFlag == true) {
                        var apps = `
                            <div class="event-box-bg" onclick="JoinFlag('` + data.Label + `')">
                                <div class="event-name-text">
                                    ` + data.Label + `
                                </div>
                                <div class="event-player-text">
                                    <span data-flagname="${data.Label}">` + data.Text + `</span> ` + data.Player + ` /  ` + data.MaxPlayer + `
                                </div>
                            </div>
                        `
                    } else {
                        var apps = `
                            <div class="event-box-bg">
                                <div class="event-name-text">
                                    ` + data.PlayerText + `
                                </div>
                                <div class="event-player-text">
                                    <span>` + data.Text + `</span>
                                </div>
                            </div>
                        `
                    }
                } else {
                    var apps = `
                        <div class="event-box-bg">
                            <div class="event-name-text">
                                ` + data.Label + `
                            </div>
                            <div class="event-player-text">
                                ` + data.Text + `
                            </div>
                        </div>
                    `
                }
                $("#Flag").append(apps);
            });
        } else if (event.data.action == 'SyncFlagTime') {
            $.each(event.data.Flag, function(index, data) {
                let Flagnumber = data.Label;
                $(`[data-flagname="${Flagnumber}"]`).text(event.data.Time)
            });
        } else if (event.data.action == 'GetWarzone') {
            $("#Warzone").empty();
            $.each(event.data.Warzone, function(index, data) {
                var apps = `
                    <div class="event-box-bg" onclick="JoinWarzone('` + data.Label + `')">
                        <div class="event-name-text">
                            ` + data.Label + `
                        </div>
                        <div class="event-player-text">
                            ` + data.Player + ` /  ` + data.MaxPlayer + `
                        </div>
                    </div>
                `
                $("#Warzone").append(apps);
            });
        } else if (event.data.action == 'GetEventMenu') {
            if (event.data.Status == true) {
                $('.exit-event-bg').fadeIn();
            } else {
                $('.event-bg').fadeIn();
            }
        } else if (event.data.action == 'GetSquad') {
            $('.squad-bg').fadeIn();
            $("#squadlist").empty();
            $.each(event.data.DataSquad, function(index, data) {
                if (data.Status == true) {
                    var apps = `
                        <div class="squad-box-bg">
                            <div class="dot-squad red"></div>
                            <div class="squad-name-box">
                                <span>` + data.Name + `</span>
                            </div>
                            <div class="squad-member-box">
                                ` + data.PlayerCount + ` / ` + data.PlayerMax + `
                            </div>
                            <div class="squad-join-box">
                                Already Started
                            <div>
                        </div>
                    `;
                } else {
                    var apps = `
                        <div class="squad-box-bg">
                            <div class="dot-squad green"></div>
                            <div class="squad-name-box">
                                <span>` + data.Name + `</span>
                            </div>
                            <div class="squad-member-box">
                                ` + data.PlayerCount + ` / ` + data.PlayerMax + `
                            </div>
                            <div class="squad-join-box" onclick="JoinSquad('` + data.Name + `')">
                                Join Squad
                            <div>
                        </div>
                    `;
                }
                $("#squadlist").append(apps);
            });
        } else if (event.data.action == 'RefreshPlayerInSquad') {
            $("#MemberSquad").empty();
            $("#ManageSquadName").html(event.data.Name);
            if (event.data.StatusSquad == true) {
                var apps = `
                    <div class="ManageSquadStatusText TextGreen">
                        <i class="fa-solid fa-circle"></i>Party has started
                    </div>
                `;
                $("#ManageSquadStatus").html(apps);
            } else {
                if (event.data.IsBossSquad == true) {
                    var apps = `
                        <div class="ManageSquadStatusButton" onclick="StartSquad()">
                            เริ่มปาร์ตี้
                        </div>
                        <div class="ManageSquadStatusText TextRed">
                            <i class="fa-solid fa-circle"></i>Not yet start party
                        </div>
                    `;
                } else {
                    var apps = `
                        <div class="ManageSquadStatusText TextRed">
                            <i class="fa-solid fa-circle"></i>Not yet start party
                        </div>
                    `;
                }
                $("#ManageSquadStatus").html(apps);
            }
            if (event.data.IsBossSquad == true) {
                var apps = `
                    <div class="ManageSquadButton" onclick="DeleteSquad()">
                        Quit Party
                    </div>
                `;
                $("#ManageSquadButton").html(apps);
            } else {
                var apps = `
                    <div class="ManageSquadButton" onclick="QuitSquad()">
                        Leave Party
                    </div>
                `;
                $("#ManageSquadButton").html(apps);
            }
            $.each(event.data.Player, function(index, data) {
                if (event.data.IsBossSquad == true) {
                    if (data.Boss == true) {
                        if (data.Status == true) {
                            var apps = `
                                <div class="MemberSquad-box-bg">
                                    <div class="icon-squad gold">
                                        <i class="fa-solid fa-crown"></i>
                                    </div>
                                    <div class="MemberSquad-name-box">
                                        ` + data.Name + `
                                    </div>
                                </div>
                            `;
                        } else {
                            var apps = `
                                <div class="MemberSquad-box-bg">
                                    <div class="icon-squad notative">
                                        <i class="fa-solid fa-crown"></i>
                                    </div>
                                    <div class="MemberSquad-name-box">
                                        ` + data.Name + `
                                    </div>
                                </div>
                            `; 
                        }
                    } else {
                        if (data.Status == true) {
                            var apps = `
                                <div class="MemberSquad-box-bg">
                                    <div class="icon-squad ative">
                                        <i class="fa-solid fa-user"></i>
                                    </div>
                                    <div class="MemberSquad-name-box">
                                        ` + data.Name + `
                                    </div>
                                    <div class="Kick-name-box" onclick="KickSquad('` + data.Identifier + `')">
                                        <i class="fa-solid fa-x"></i>
                                    </div>
                                </div>
                            `;
                        } else {
                            var apps = `
                                <div class="MemberSquad-box-bg">
                                    <div class="icon-squad notative">
                                        <i class="fa-solid fa-user"></i>
                                    </div>
                                    <div class="MemberSquad-name-box">
                                        ` + data.Name + `
                                    </div>
                                    <div class="Kick-name-box" onclick="KickSquad('` + data.Identifier + `')">
                                        <i class="fa-solid fa-x"></i>
                                    </div>
                                </div>
                            `;
                        }
                    }
                } else {
                    if (data.Boss == true) {
                        if (data.Status == true) {
                            var apps = `
                                <div class="MemberSquad-box-bg">
                                    <div class="icon-squad gold">
                                        <i class="fa-solid fa-crown"></i>
                                    </div>
                                    <div class="MemberSquad-name-box">
                                        ` + data.Name + `
                                    </div>
                                </div>
                            `;
                        } else {
                            var apps = `
                                <div class="MemberSquad-box-bg">
                                    <div class="icon-squad notative">
                                        <i class="fa-solid fa-crown"></i>
                                    </div>
                                    <div class="MemberSquad-name-box">
                                        ` + data.Name + `
                                    </div>
                                </div>
                            `; 
                        }
                    } else {
                        if (data.Status == true) {
                            var apps = `
                                <div class="MemberSquad-box-bg">
                                    <div class="icon-squad ative">
                                        <i class="fa-solid fa-user"></i>
                                    </div>
                                    <div class="MemberSquad-name-box">
                                        ` + data.Name + `
                                    </div>
                                </div>
                            `;
                        } else {
                            var apps = `
                                <div class="MemberSquad-box-bg">
                                    <div class="icon-squad notative">
                                        <i class="fa-solid fa-user"></i>
                                    </div>
                                    <div class="MemberSquad-name-box">
                                        ` + data.Name + `
                                    </div>
                                </div>
                            `;
                        }
                    }
                }
                $("#MemberSquad").append(apps);
            });
        } else if (event.data.action == 'ManageSquad') {
            $('.mamage-squad-bg').fadeIn();
            $("#MemberSquad").empty();
            $("#ManageSquadName").html(event.data.Name);
            if (event.data.StatusSquad == true) {
                var apps = `
                    <div class="ManageSquadStatusText TextGreen">
                        <i class="fa-solid fa-circle"></i>ปาร์ตี้เริ่มแล้ว
                    </div>
                `;
                $("#ManageSquadStatus").html(apps);
            } else {
                if (event.data.IsBossSquad == true) {
                    var apps = `
                        <div class="ManageSquadStatusButton" onclick="StartSquad()">
                            เริ่มปาร์ตี้
                        </div>
                        <div class="ManageSquadStatusText TextRed">
                            <i class="fa-solid fa-circle"></i>Not yet start party
                        </div>
                    `;
                } else {
                    var apps = `
                        <div class="ManageSquadStatusText TextRed">
                            <i class="fa-solid fa-circle"></i>Not yet start party
                        </div>
                    `;
                }
                $("#ManageSquadStatus").html(apps);
            }
            if (event.data.IsBossSquad == true) {
                var apps = `
                    <div class="ManageSquadButton" onclick="DeleteSquad()">
                        Quit Party
                    </div>
                `;
                $("#ManageSquadButton").html(apps);
            } else {
                var apps = `
                    <div class="ManageSquadButton" onclick="QuitSquad()">
                        Leave Party
                    </div>
                `;
                $("#ManageSquadButton").html(apps);
            }
            $.each(event.data.Player, function(index, data) {
                if (event.data.IsBossSquad == true) {
                    if (data.Boss == true) {
                        if (data.Status == true) {
                            var apps = `
                                <div class="MemberSquad-box-bg">
                                    <div class="icon-squad gold">
                                        <i class="fa-solid fa-crown"></i>
                                    </div>
                                    <div class="MemberSquad-name-box">
                                        ` + data.Name + `
                                    </div>
                                </div>
                            `;
                        } else {
                            var apps = `
                                <div class="MemberSquad-box-bg">
                                    <div class="icon-squad notative">
                                        <i class="fa-solid fa-crown"></i>
                                    </div>
                                    <div class="MemberSquad-name-box">
                                        ` + data.Name + `
                                    </div>
                                </div>
                            `; 
                        }
                    } else {
                        if (data.Status == true) {
                            var apps = `
                                <div class="MemberSquad-box-bg">
                                    <div class="icon-squad ative">
                                        <i class="fa-solid fa-user"></i>
                                    </div>
                                    <div class="MemberSquad-name-box">
                                        ` + data.Name + `
                                    </div>
                                    <div class="Kick-name-box" onclick="KickSquad('` + data.Identifier + `')">
                                        <i class="fa-solid fa-x"></i>
                                    </div>
                                </div>
                            `;
                        } else {
                            var apps = `
                                <div class="MemberSquad-box-bg">
                                    <div class="icon-squad notative">
                                        <i class="fa-solid fa-user"></i>
                                    </div>
                                    <div class="MemberSquad-name-box">
                                        ` + data.Name + `
                                    </div>
                                    <div class="Kick-name-box" onclick="KickSquad('` + data.Identifier + `')">
                                        <i class="fa-solid fa-x"></i>
                                    </div>
                                </div>
                            `;
                        }
                    }
                } else {
                    if (data.Boss == true) {
                        if (data.Status == true) {
                            var apps = `
                                <div class="MemberSquad-box-bg">
                                    <div class="icon-squad gold">
                                        <i class="fa-solid fa-crown"></i>
                                    </div>
                                    <div class="MemberSquad-name-box">
                                        ` + data.Name + `
                                    </div>
                                </div>
                            `;
                        } else {
                            var apps = `
                                <div class="MemberSquad-box-bg">
                                    <div class="icon-squad notative">
                                        <i class="fa-solid fa-crown"></i>
                                    </div>
                                    <div class="MemberSquad-name-box">
                                        ` + data.Name + `
                                    </div>
                                </div>
                            `; 
                        }
                    } else {
                        if (data.Status == true) {
                            var apps = `
                                <div class="MemberSquad-box-bg">
                                    <div class="icon-squad ative">
                                        <i class="fa-solid fa-user"></i>
                                    </div>
                                    <div class="MemberSquad-name-box">
                                        ` + data.Name + `
                                    </div>
                                </div>
                            `;
                        } else {
                            var apps = `
                                <div class="MemberSquad-box-bg">
                                    <div class="icon-squad notative">
                                        <i class="fa-solid fa-user"></i>
                                    </div>
                                    <div class="MemberSquad-name-box">
                                        ` + data.Name + `
                                    </div>
                                </div>
                            `;
                        }
                    }
                }
                $("#MemberSquad").append(apps);
            });
        }
    })
})

function PlaySounds(name) {
    var sound = new Audio(`sounds/` + name + `.mp3`);
    sound.volume = 0.5;
    sound.play();
}
// 
function EventMenu() {
    PlaySounds("click")
    $('.main-bg').fadeOut();
    SendMessage("GetEventMenu", {});
}

function CloseEventMenu() {
    PlaySounds("click")
    $('.event-bg').fadeOut();
    $('.exit-event-bg').fadeOut();
    $('.main-bg').fadeIn();
}

function ExitEvent() {
    PlaySounds("click")
    closemenu();
    SendMessage("ExitEvent", {});
}
// Airdrop
function AirdropMenu() {
    PlaySounds("click")
    $('.event-bg').fadeOut();
    $('.airdrop-bg').fadeIn();
    SendMessage("GetAirdrop", {});
}

function CloseAirdropMenu() {
    PlaySounds("click")
    $('.airdrop-bg').fadeOut();
    $('.event-bg').fadeIn();
}

function JoinAirdrop(name) {
    PlaySounds("click")
    closemenu();
    SendMessage("JoinAirdrop", {
        Name: name,
    });
}

// Flag
function FlagMenu() {
    PlaySounds("click")
    $('.event-bg').fadeOut();
    $('.flag-bg').fadeIn();
    SendMessage("GetFlag", {});
}

function CloseFlagMenu() {
    PlaySounds("click")
    $('.flag-bg').fadeOut();
    $('.event-bg').fadeIn();
}

function JoinFlag(name) {
    PlaySounds("click")
    closemenu();
    SendMessage("JoinFlag", {
        Name: name,
    });
}

// Warzone
function WarzoneMenu() {
    PlaySounds("click")
    $('.event-bg').fadeOut();
    $('.warzone-bg').fadeIn();
    SendMessage("GetWarzone", {});
}

function CloseWarzoneMenu() {
    PlaySounds("click")
    $('.warzone-bg').fadeOut();
    $('.event-bg').fadeIn();
}

function JoinWarzone(name) {
    PlaySounds("click")
    closemenu();
    SendMessage("JoinWarzone", {
        Name: name,
    });
}
// Squad
function SquadMenu() {
    PlaySounds("click")
    $('.event-bg').fadeOut();
    SendMessage("GetSquad", {});
}

function CloseSquadMenu() {
    PlaySounds("click")
    $('.main-bg').fadeIn();
    $('.squad-bg').fadeOut();
    $('.mamage-squad-bg').fadeOut();
    document.getElementById('myInput2').value = ''
}

function CreateSquad() {
    PlaySounds("click")
    $('.CreateSquadInput').fadeIn();
}

function CreateParty() {
    PlaySounds("click")
    if ($("#SquadName").val() !== '') {
        SendMessage("CreateParty", {
            name: $("#SquadName").val()
        });
        $('.CreateSquadInput').fadeOut();
        setTimeout(() => {
            SendMessage("GetSquad", {});
        }, 1000);
    }
}

function CancelCreateParty() {
    PlaySounds("click")
    $('.CreateSquadInput').fadeOut();
    document.getElementById('SquadName').value = ''
}

function myFunction2() {
    var input, filter, ul, li, a, i, txtValue;
    input = document.getElementById("myInput2");
    filter = input.value.toUpperCase();
    ul = document.getElementById("squadlist");
    li = ul.getElementsByClassName("squad-box-bg");
    for (i = 0; i < li.length; i++) {
        a = li[i].getElementsByTagName("span")[0];
        txtValue = a.textContent || a.innerText;
        if (txtValue.toUpperCase().indexOf(filter) > -1) {
            li[i].style.display = "";
        } else {
            li[i].style.display = "none";
        }
    }
}

function JoinSquad(name) {
    PlaySounds("click")
    SendMessage("JoinSquad", {
        name: name
    });
    setTimeout(() => {
        SendMessage("GetSquad", {});
    }, 500);
}

function KickSquad(name) {
    PlaySounds("click")
    SendMessage("KickSquad", {
        name: name
    });
}


function QuitSquad() {
    PlaySounds("click")
    $(".QuitSquad").fadeIn();
}

function SubmitQuitSquad() {
    PlaySounds("click")
    $(".QuitSquad").fadeOut();
    closemenu();
    SendMessage("SubmitQuitSquad", {});
}

function CancelQuitSquad() {
    PlaySounds("click")
    $(".QuitSquad").fadeOut();
}

function DeleteSquad() {
    PlaySounds("click")
    $(".DeleteSquad").fadeIn();
}

function SubmitDeleteSquad() {
    PlaySounds("click")
    $(".DeleteSquad").fadeOut();
    closemenu();
    SendMessage("SubmitDeleteSquad", {});
}

function CancelDeleteSquad() {
    PlaySounds("click")
    $(".DeleteSquad").fadeOut();
}

function StartSquad() {
    PlaySounds("click")
    SendMessage("StartSquad", {});
}

// 
function FamilyMenu() {
    PlaySounds("click")
    $('.main-bg').fadeOut();
    $('.family-bg').fadeIn();
    $(".searchfamily").fadeIn();
    $(".gangdetailnoinfo").fadeIn();
    $(".seemember-bg").fadeOut();
    $(".ganglist").fadeIn();
    $(".gangdetailinfo").fadeOut();
    SendMessage("GetFamily", {});
}

function CloseFamilyMenu() {
    PlaySounds("click")
    $('.family-bg').fadeOut();
    $(".seemember-bg").fadeOut();
    $(".ManageFamilyBG").fadeOut();
    $("#ManageMemberBG").empty();
    $("#familylist").empty();
    $("#familydetail").empty();
    document.getElementById('myInput').value = ''
    $('.main-bg').fadeIn();
}

function CreateFamilyMenu() {
    PlaySounds("click")
    $(".CreateFamily").fadeIn();
}

function ManageFamily() {
    PlaySounds("click")
    SendMessage("GetManageFamily", {});
    $(".gangdetailnoinfo").fadeOut();
    $(".seemember-bg").fadeOut();
    $(".gangdetailinfo").fadeOut();
    $(".searchfamily").fadeOut();
    $(".ganglist").fadeOut();
    $(".ManageFamilyBG").fadeIn();
}

function SubmitManage() {
    PlaySounds("click")
    SendMessage("SubmitManage", {
        Name: $("#ManageName").val(),
        Img: $("#ManageImg").val(),
        Bio: $("#ManageBio").val()
    });
}

function ManageRequestBottomMenu() {
    PlaySounds("click")
    SendMessage("GetManageRequest", {});
    $(".ManageRequestBG").fadeIn();
}

function QuitFamily() {
    PlaySounds("click")
    $(".QuitFamily").fadeIn();
}

function SubmitQuitFamily() {
    PlaySounds("click")
    $(".QuitFamily").fadeOut();
    closemenu();
    SendMessage("SubmitQuitFamily", {});
}

function CancelQuitFamily() {
    PlaySounds("click")
    $(".QuitFamily").fadeOut();
}

function CloseRequestBottom() {
    PlaySounds("click")
    $(".ManageRequestBG").fadeOut();
    $("#ManageRequestBG").empty();
}

function Accept(name) {
    PlaySounds("click")
    SendMessage("AccpetRequest", {
        Name: name
    });
}
function Deny(name) {
    PlaySounds("click")
    SendMessage("DenyRequest", {
        Name: name
    });
}

function Kick(name) {
    PlaySounds("click")
    SendMessage("KickPlayer", {
        Name: name
    });
}

function DeleteFamily() {
    PlaySounds("click")
    $(".DeleteFamily").fadeIn();
}

function SubmitDeleteFamily() {
    PlaySounds("click")
    $(".DeleteFamily").fadeOut();
    closemenu();
    SendMessage("SubmitDeleteFamily", {});
}

function CancelDeleteFamily() {
    PlaySounds("click")
    $(".DeleteFamily").fadeOut();
}

function UpGrageSlot() {
    PlaySounds("click")
    $(".UpGrageSlot").fadeIn();
}

function SubmitUpGrageSlot() {
    PlaySounds("click")
    $(".UpGrageSlot").fadeOut();
    closemenu();
    SendMessage("SubmitUpGrageSloty", {});
}

function CancelUpGrageSlot() {
    PlaySounds("click")
    $(".UpGrageSlot").fadeOut();
}

let Player = null
function UpRank(name) {
    PlaySounds("click")
    SendMessage("GetRank", {});
    $(".UpRank").fadeIn();
    Player = name
}

function SubmitUpRank() {
    PlaySounds("click")
    $(".UpRank").fadeOut();
    closemenu();
    SendMessage("UpRank", {
        Name: Player,
        Rank: $("#all-rank").val(),
    });
    Player = null
}

function CancelUpRank() {
    PlaySounds("click")
    $("#all-rank").empty();
    $(".UpRank").fadeOut();
}

function CreateFamily() {
    PlaySounds("click")
    if ($("#FamilyName").val() !== '') {
        SendMessage("CreateFamily", {
            name: $("#FamilyName").val()
        });
        closemenu();
    }
}

function CancelCreateFamily() {
    PlaySounds("click")
    $(".CreateFamily").fadeOut();
}

function myFunction() {
    var input, filter, ul, li, a, i, txtValue;
    input = document.getElementById("myInput");
    filter = input.value.toUpperCase();
    ul = document.getElementById("familylist");
    li = ul.getElementsByClassName("gang-box-bg");
    for (i = 0; i < li.length; i++) {
        a = li[i].getElementsByTagName("span")[0];
        txtValue = a.textContent || a.innerText;
        if (txtValue.toUpperCase().indexOf(filter) > -1) {
            li[i].style.display = "";
        } else {
            li[i].style.display = "none";
        }
    }
}

function Seeinfo(name) {
    PlaySounds("click")
    $("#familydetail").empty();
    $(".seemember-bg").fadeOut();
    $(".gangdetailnoinfo").fadeOut();
    $(".gangdetailinfo").fadeIn();
    SendMessage("GetFamilyInfo", {
        name: name
    });
}

function ApplyFamily(name) {
    PlaySounds("click")
    SendMessage("ApplyFamily", {
        name: name
    });
    closemenu();
}

function SeeMember(name) {
    PlaySounds("click")
    SendMessage("SeeMember", {
        name: name
    });
}

function CloseSeeMemberMenu() {
    PlaySounds("click")
    $(".seemember-bg").fadeOut();
}

function myFunction3() {
    var input, filter, ul, li, a, i, txtValue;
    input = document.getElementById("myInput3");
    filter = input.value.toUpperCase();
    ul = document.getElementById("memberlist");
    li = ul.getElementsByClassName("memberlist-box");
    for (i = 0; i < li.length; i++) {
        a = li[i].getElementsByTagName("span")[0];
        txtValue = a.textContent || a.innerText;
        if (txtValue.toUpperCase().indexOf(filter) > -1) {
            li[i].style.display = "";
        } else {
            li[i].style.display = "none";
        }
    }
}

// 
function ShopMenu() {
    PlaySounds("click")
    $('.main-bg').fadeOut();
    $('.shop-bg').fadeIn();
    SendMessage("GetShop", {});
}

function CloseShopMenu() {
    PlaySounds("click")
    $('.shop-bg').fadeOut();
    $('.main-bg').fadeIn();
}

function BuyItem(name) {
    PlaySounds("click")
    itembuy = name
    $('.InputItemCount').fadeIn();
}

function SubmitBuyItem() {
    PlaySounds("click")
    if ($("#InputItemCount").val() !== '') {
        SendMessage("BuyItem", {
            Name: itembuy,
            Count: $("#InputItemCount").val()
        });
        closemenu();
    }
    itembuy = null
    document.getElementById('InputItemCount').value = ''
}

function CancelBuyItem() {
    PlaySounds("click")
    $(".InputItemCount").fadeOut();
    itembuy = null
    document.getElementById('InputItemCount').value = ''
}